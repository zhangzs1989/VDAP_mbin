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
% for spectral plot option, hard code for now (TODO)
nfft=1024; %1024
freqHi = 25;
s = spectralobject(nfft,nfft*.86,freqHi,[0 120]); % for counts
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
    
    [~,picks,event] = readQuakeML(quakeMLfile);
    if ~isfield(event,'Magnitude') || isempty(event.Magnitude)
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
    
    
%     datas3 = zeros(numel(picks),params.templateLen*sr);  %[];
    try %JP
        w1.w = w;
        w1.i = m;
        w1.t = t1;

        F = NMFwaveformfig(w1,[],params);
        print(F,[QCdir,filesep,datestr(templtime,30),'_',int2str(quakeID),'w.png'],'-dpng')

        if strcmp(params.vis,'off')
            close(F)
        end
    catch
        warning('Not able to make figure')
    end
    % insert spectrogram figure here
    try
        figure('visible',params.vis), hold on
        try
            specgram2JP(s,w,'xunit','date','colorbar','none'); % 2JP is version with spectra plot added along y-axis, can use other version too
        catch
            s=set(s,'nfft',get(s,'nfft')/2);
            specgram2JP(s,w,'xunit','date','colorbar','none'); % 2JP is version with spectra plot added along y-axis, can use other version too
        end
        print([QCdir,filesep,datestr(templtime,30),'_',int2str(quakeID),'s.png'],'-dpng')
    
        if strcmp(params.vis,'off')
            close(F)
        end
    catch
        warning('Not able to make spec figure')
    end
    
end

end