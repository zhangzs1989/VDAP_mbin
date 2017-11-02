clear
%% MAIN code to run the Network Matched Filter

tic
inputFile = '/Users/jpesicek/Dropbox/VDAP/Responses/Agung/NMF2/NMF_input.txt';
[inputs,params] = getInputFiles(inputFile);
[~,~,~] = mkdir(fullfile(inputs.outDir));
QCdir=[inputs.outDir,filesep,'templates'];
[~,~,~] = mkdir(QCdir);
NMFeventFile=[QCdir,filesep,params.strRunName,'_NMFtemplateFile.txt'];
NEICeventFile=[QCdir,filesep,params.strRunName,'_OTs_NEICformat.txt'];
NMFoutFile =[inputs.outDir,filesep,params.strRunName,'_NMFoutFile.txt'];

diaryFileName = fullfile(inputs.outDir,['/loc_',datestr(now,30),'_diary.txt']);
diary(diaryFileName);
disp(datetime)
details(inputs)
details(params)

[qmllist,result] = readtext(inputs.quakeMLfileList,',','#');

f=filterobject('B',[params.flo params.fhi],3);
preTime = 0; %start template this many secs before template time
sr = params.newSampleRate;
fid2=fopen(NMFeventFile,'w');
fid3=fopen(NEICeventFile,'w');
mags = 2;
%%
for l = 1:length(qmllist)
    
    quakeMLfile = char(qmllist(l,2));
    quakeID = cell2mat(qmllist(l,1));
    disp(['EVENT# ',int2str(quakeID),', ',quakeMLfile])
    
    picks = readQuakeML(quakeMLfile);
    if ~params.offsetsTF
        templtime = min(extractfield(picks,'dn')); % template start time
    else
        error('TO DO: implement template delays')
    end
    t1=templtime-datenum(0,0,0,0,0,preTime);
    t2=templtime+datenum(0,0,0,0,0,params.templateLen);
    fprintf(fid3,'%s %2.1f\n',datestr(t1,'yyyy-mm-ddTHH:MM:SSZ'),mags);
    disp([datestr(t1,'yyyymmddHHMMSS.FFF'),' '])

    ct = 0;
    for m = 1:numel(picks)
        scnl = scnlobject(picks(m).sta,picks(m).chan,picks(m).net,picks(m).loc);
        ct = ct + 1;
        try
            w(ct) = load_waveformObject_VDAP(inputs.ds,scnl,t1,t2,sr);
            w(ct) = demean(w(ct));
            sampleRate=get(w(ct),'freq');
            w(ct) = fix_data_length(w(ct),params.templateLen*sampleRate); %JP add to fix parfor assignment error
            fprintf(fid2,'%d %s %s %s %s %s %2.1f\n',quakeID,datestr(t1,'dd-mmm-yyyy HH:MM:SS'),picks(m).net,picks(m).sta,picks(m).chan,picks(m).loc,mags);
        catch
            disp('problem loading waveform, padding with zeroes');
            disp(['cannot load ',get(scnl,'station'),' ',get(scnl,'channel')])
            w(ct) = waveform(get(scnl,'station'),get(scnl,'channel'),sr,t1,zeros(etime(datevec(t2),datevec(t1))*sr,1));
        end
    end
    
    datas3 = zeros(numel(picks),params.templateLen*sr);  %[];
    try %JP
        figure('visible',params.vis), hold on
        count = 1;
        
        for jj = 1:numel(picks)
            wd = get(w(count),'DATA');
            wstr = [get(w(count),'station'),', ',get(w(count),'channel')];
            datas3(count,1:params.templateLen*sr) = bandpass(wd,params.flo,params.fhi,1/sr,3);
            
            plot(1:length(datas3(count,:)),datas3(count,:)./max(datas3(count,:))+count*2,'b')
            text(length(datas3(count,:))-20,count*2,wstr,'color','k','BackgroundColor','w','interpreter','none','fontsize',9)
%             text(0,count*2,num2str(maxcorrs(count,each_match),'%.2f'),'BackgroundColor','w'); % currently showing max for day, not match. Should update
            count = count+1;
        end
        text(length(datas3(count-1,:))-150,1,['bandpass = ',num2str(params.flo),' to ',num2str(params.fhi)]) %std of day maxes, not match.  Should update
        title(['{\color{blue}Template ',int2str(l),'@',datestr(t1,'mm/dd/yyyy HH:MM:SS'),'}']) %,',} {\color{red}Match ',int2str(good_matches_ct),'@',datestr(to_output(each_match),'mm/dd/yyyy HH:MM:SS'),'}, CCC: ',num2str(output_data(each_match,1),'%3.1f')])
        xlabel('sample since template start')
        set(gca,'YTickLabel',[])
        set(gca,'YTick',[])
        box on, grid on
        print([QCdir,filesep,datestr(templtime,30),'_',int2str(quakeID),'.png'],'-dpng')
        if strcmp(params.vis,'off')
            close(gcf)
        end
    catch
        warning('Not able to make figure')
    end

end
%% Now do NMF
runNMF(inputs,params,NMFeventFile,NMFoutFile)
%% Now combine all matches for all templates into one catalog removing repeats
combineCatalogs(params,inputs)
%%
plotNMFresults(inputs,params)
%%
toc
diary OFF