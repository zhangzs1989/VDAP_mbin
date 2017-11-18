function [NMFeventFile, template_numbers] = getTemplates(inputs,params)

%TODO: make spectrograms of tmeplates
QCdir=[inputs.outDir,filesep,'templates'];
[~,~,~] = mkdir(QCdir);

[template_numbers,qmllist] = getTemplateInfo(params,inputs);

NMFeventFile=[QCdir,filesep,params.strRunName,'_NMFtemplateFile.txt'];
NEICeventFile=[QCdir,filesep,params.strRunName,'_OTs_NEICformat.txt'];

% f=filterobject('B',[params.flo params.fhi],3);
preTime = 0; %start template this many secs before template time
sr = params.newSampleRate;
fid2=fopen(NMFeventFile,'w');
fid3=fopen(NEICeventFile,'w');
defaultMag = 2;

%%
for l = 1:length(qmllist)
    
    if size(qmllist,2)>1
        quakeMLfile = char(qmllist(l,2));
        quakeID = cell2mat(qmllist(l,1));
    else
        quakeMLfile = char(qmllist(l));
        quakeID = l;
    end
    disp(['EVENT# ',int2str(quakeID),', ',quakeMLfile])
    
    [picks,event] = readQuakeML(quakeMLfile);
    if ~isfield(event,'Magnitude')
        event.Magnitude = defaultMag;
    end
    if ~params.useLags
        templtime = min(extractfield(picks,'dn')); % template start time
    else
        error('TO DO: implement template delays')
    end
    t1=templtime-datenum(0,0,0,0,0,preTime);
    t2=templtime+datenum(0,0,0,0,0,params.templateLen);
    fprintf(fid3,'%s %2.1f\n',datestr(t1,'yyyy-mm-ddTHH:MM:SSZ'),event.Magnitude);
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
            fprintf(fid2,'%d %s %s %s %s %s %2.1f\n',quakeID,datestr(t1,'dd-mmm-yyyy HH:MM:SS'),picks(m).net,picks(m).sta,picks(m).chan,picks(m).loc,defaultMag);
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
            text(length(datas3(count,:))-20,count*2,wstr,'color','k','BackgroundColor','w','interpreter','none','fontsize',9,'EdgeColor','k')
            count = count+1;
        end
        text(length(datas3(count-1,:))-150,1,['BP = ',num2str(params.flo),'-',num2str(params.fhi),' Hz'],'BackgroundColor','w','EdgeColor','k') %std of day maxes, not match.  Should update
        title(['{\color{blue}Template ',int2str(l),'@',datestr(t1,'mm/dd/yyyy HH:MM:SS'),'}'])
        xlabel('samples since template start')
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


end