function plotNMFhelicorders(inputs,params,stationLabel)

startDate = params.startDate;
endDate = params.stopDate;
plotThres = params.min_threshold;

baseDir=inputs.outDir;
ds = inputs.ds;
outDir = baseDir;

f=filterobject('b',[params.flo,params.fhi],3);
resultsFile=fullfile(baseDir,'NMF',filesep,[params.strRunName,'_NMFcatalog.txt']);

FID_results = fopen(resultsFile);
if FID_results == -1
    error(['Unable to open variable file '])
end

templateFile2=fullfile(baseDir,'templates/',[params.strRunName,'_NMFtemplateFile.txt']); %JP
templates2 = readtext(templateFile2,' ','','','textual');

FID_results = fopen(resultsFile);
Combined_Results_lines = textscan(FID_results, '%s', 'delimiter', '\n');

for i=1:size(templates2,1)
    scnl(i)=scnlobject(templates2(i,5),templates2(i,6),templates2(i,4),templates2(i,7));
    CT(i) = ChannelTag(get(scnl(i),'network'),get(scnl(i),'station'),get(scnl(i),'location'),get(scnl(i),'channel'));
end
uCTs = unique(CT);
nsta = length(uCTs);

for i=1:nsta
    lab{i}=[get(scnl(i),'station'),'_',get(scnl(i),'channel'),'_',get(scnl(i),'network')];
end

count=0;
for each_line=1:1:length(Combined_Results_lines{1})
    try
        line=textscan(char(Combined_Results_lines{1}(each_line)),'%s %s %f %f %d %d %f');
        % NOTE: If you only want to plot higher threshold matches
        if(line{3}<plotThres)
            continue
        end
        count=count+1;
        
        match_time(count)=datenum([char(line{1}) ' ' char(line{2})]);
        %         ccc(count)=line{3};
        %         template_matched(count)=line{5};
        %         stc(count)=line{6};
        %         ncc(count)=double(line{3})/double(line{6});
    end
end

%% make catalog obj
for i=1:length(match_time)
    otime(i) = match_time(i);
    ontime(i)=otime(i);
    offtime(i)=otime(i)+datenum(0,0,0,0,0,25);
end
cobj = Catalog('otime',otime,'ontime',ontime,'offtime',offtime);

si = strcmp(lab,stationLabel);
%% plot helicorders (this is slow, downsample?). only using first station
for day=startDate:endDate
    
    I = otime>day & otime<=day+1;
    if sum(I)>0
        w=load_waveformObject_VDAP(ds,scnl(si),day,day+1,40);
        %         w = waveform(ds,scnl,day,day+1);
        w = fillgaps(w, 'interp');
        w = detrend(w);
        w = filtfilt(f, w);
        
        %% Plot detected events on top of the continuous drumplot
        h3 = drumplot(w, 'mpl', 30, 'catalog', cobj);
        plot(h3)
        print(gcf,fullfile(outDir,'NMF',[datestr(day,'yyyymmdd'),'drum']),'-dpng')
    end
    
end
end