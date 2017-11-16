function plotNMFresults(inputs,params)

t_pre = 0;
t_post= 10;
startDate = params.startDate;
endDate = params.stopDate;
plotThres = params.min_threshold;

baseDir=inputs.outDir;
ds = inputs.ds;
outDir = baseDir;
% outDir = fullfile(baseDir,'outFigs');
% [SUCCESS,MESSAGE,MESSAGEID] = mkdir(outDir);

f=filterobject('b',[params.flo,params.fhi],3);
resultsFile=fullfile(baseDir,'NMF',filesep,[params.strRunName,'_NMFcatalog.txt']);
% results = dlmread(resultsFile);
% figure,hist((results(:,2)))
% xlabel('CCC')
% title('CCC')
% print(fullfile(QCdir,'CCC_hist.png'),'-dpng')

FID_results = fopen(resultsFile);
if FID_results == -1
    error(['Unable to open variable file '])
end

templateFile=fullfile(baseDir,'templates/',[params.strRunName,'_OTs_NEICformat.txt']); %JP
templates = readtext(templateFile);
% templates = templates(3); % NOTE!!!
templateFile2=fullfile(baseDir,'templates/',[params.strRunName,'_NMFtemplateFile.txt']); %JP
templates2 = readtext(templateFile2,' ','','','textual');

for i=1:size(templates2,1)
    scnl(i)=scnlobject(templates2(i,5),templates2(i,6),templates2(i,4),templates2(i,7));
    CT(i) = ChannelTag(get(scnl(i),'network'),get(scnl(i),'station'),get(scnl(i),'location'),get(scnl(i),'channel'));
end
uCTs = unique(CT);
nsta = length(uCTs);

%Which station/channel to use to calculate Ml and plot sequence.
% scnl(1)=scnlobject('TMKS','EHZ','VG','--');
% CT = ChannelTag(get(scnl,'network'),get(scnl,'station'),get(scnl,'location'),get(scnl,'channel'));
% scnl(2)=scnlobject('CERB','SHE','AV','--');
% scnl(3)=scnlobject('CERB','SHN','AV','--');

for i=1:nsta
    lab{i}=[get(scnl(i),'station'),'_',get(scnl(i),'channel'),'_',get(scnl(i),'network')];
end

for sta=1:nsta
    
    % Reads variable inputs from txt file
    FID_results = fopen(resultsFile);
    Combined_Results_lines = textscan(FID_results, '%s', 'delimiter', '\n');
    
    match_time=[];
    ccc=[];
    template_matched=[];
    matches=[];
    filtered_matches=[];
    filtered_matches1=[]; %JP add
    amplitude=[];
    ncc=[];stc=[];
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
            ccc(count)=line{3};
            template_matched(count)=line{5};
            stc(count)=line{6};
            ncc(count)=double(line{3})/double(line{6});
            %Adjust timing in line below to grab waveforms over earthquake only
            % NOTE change these data gabbing routines to lines 377++ in
            % cross_corr_AK.m
            
            matches1=load_waveformObject_VDAP(ds,scnl(sta),match_time(count),match_time(count)+datenum(0,0,0,0,0,t_post),40);
            matches1=align(matches1,match_time(count),get(matches1,'freq'));
            
            filtered_matches1=filtfilt(f,matches1);
            waveform_output=get(filtered_matches1,'DATA');
            amplitude(count)=max(abs(waveform_output));
            %clear matches1 filtered_matches1 waveform_output
        catch exception
            amplitude(count)=0;
        end
        filtered_matches=[filtered_matches filtered_matches1];
        
    end
    
    Mc=-1;
    %% JP add
    tc = 0;
    for i=sort(unique(template_matched)) % templates
        tc = tc+1;
        % get template mag
%         templcoli = strfind(char(templates(i)),' ');
        templdata = char(templates(tc));
        templdata=textscan(char(templates(tc)),'%s %s %s %s %s','delimiter',' ','MultipleDelimsAsOne',1);
        
        templmag(i) = str2double(templdata{2});
        templtime(i) = datenum(templdata{1},'yyyy-mm-ddTHH:MM:SSZ');
        %         templmag(i) = str2double(templdata{5});
        %         templlat(i) = str2double(templdata{2});
        %         templlon(i) = str2double(templdata{3});
        %         templdep(i) = str2double(templdata{4});
        
        % get template matches
        temp_ind=find(template_matched==i);
        [temp_ccc_max,temp_ccc_max_ind]=max(ccc(temp_ind));
        % !! max not always template! (JP)
        
        % this is the factor to match the amplitude with the known magnitude
        fac(i) = amplitude(temp_ind(temp_ccc_max_ind))/10^(templmag(i));
        
        % double check math
        %     M = log10(amplitude(temp_ind(temp_ccc_max_ind))/fac(i));
    end
    
    % now compute Ml based on matched Mag from template input file
    for i=1:count
        Ml(i) = log10(amplitude(i)/fac(template_matched(i)));
    end
    
    %%
    %Only keep earthquakes above completeness
    Ml_keep_ind=find(Ml>Mc);
    Ml_keep=Ml(Ml_keep_ind);
    CC_keep=ccc(Ml_keep_ind);
    ncc_keep=ncc(Ml_keep_ind);
    match_time_keep=match_time(Ml_keep_ind);
    %     match_time_keep = match_time;
    
    %     %Find best match for each template. If master event is in here,
    %     for i=sort(unique(template_matched))
    %         temp_ind=find(template_matched==i);
    %         [temp_ccc_max,temp_ccc_max_ind]=max(ccc(temp_ind));
    %         match_time_best(i)=match_time(temp_ind(temp_ccc_max_ind));
    %         Ml_best_ind(i)=Ml(temp_ind(temp_ccc_max_ind));
    %         CC_best_ind(i)=ccc(temp_ind(temp_ccc_max_ind));
    %     end
    
    %JP: above doesn't always work to find template, need to normalize by
    %station count or something. now just match template time
    % NOTE: if this below doesn't work it's b/c your template didn't find
    % itself! check your times
    for i=sort(unique(template_matched))
        temp_ind = find(match_time_keep==templtime(i));
        if isempty(temp_ind)
            warning('cannot find self correlation')
            minLag = min(abs(match_time_keep - templtime(i)));
            temp_ind = find(abs(match_time_keep - templtime(i))==minLag);
            et = etime(datevec(templtime(i)),datevec(match_time_keep(temp_ind)));
            disp(['lag time (seconds) between template and closest match: ',num2str(et)])
            if et > 1
                error('FATAL: No self correlation found')
            end
        end
        [temp_ccc_max,temp_ccc_max_ind]=max(ccc(temp_ind));
        match_time_best(i)=match_time(temp_ind(temp_ccc_max_ind));
        Ml_best_ind(i)=Ml(temp_ind(temp_ccc_max_ind));
        CC_best_ind(i)=ccc(temp_ind(temp_ccc_max_ind));
        ncc_best_ind(i)=ncc(temp_ind(temp_ccc_max_ind));
    end
    %%
    %     etimes = [
    % 201704121230
    % 201704220916
    % 201704221003
    % 201704221312
    % 201704221314
    % 201704221428
    % 201704221432
    % 201704221612
    % 201704231525
    %     ];
    %
    % tstart = datenum(2017,4,1);
    % tstop = datenum(2017,4,30);
    %
%     if ~exist(fullfile(baseDir,'RSAM_OBJ.mat'),'file')
%         [ RSAM_OBJ ] = quickRSAM( ds, CT, startDate, endDate, 'rms', 1,f);
%         save(fullfile(baseDir,'RSAM_OBJ.mat'),'RSAM_OBJ')
%     else
%         load(fullfile(baseDir,'RSAM_OBJ.mat'))
%     end
%     %
%     h=plot(RSAM_OBJ, 'Xunit', 'date');
%     rsamx = h.XData;
    scrsz = get(groot,'ScreenSize');
    figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/1]);hold on
    
%     ax(4)=subplot(4,1,4);
%     rsam = get(RSAM_OBJ,'data');
%     plot(rsamx,rsam)
%     xlim([startDate endDate])
%     %     ymax = max(get(RSAM_OBJ,'data'))/200;
%     %     ymax = 7000;
%     %     ylim([0 ymax])
%     %
%     datetickJP('x','dd-mmm','keeplimits','keepticks')
%     set(gca,'xminortick','on')
%     ylabel('RSAM','FontSize',12,'FontWeight','Bold')
%     xlabel('Date Time','FontSize',12,'FontWeight','Bold')
%     hold on, grid on, box on
%     title((lab{sta}),'interpreter','none','FontSize',12,'FontWeight','Bold')
    %     for i=1:length(etimes)
    %         plot([datenum(int2str(etimes(i)),'yyyymmddHHMM'),datenum(int2str(etimes(i)),'yyyymmddHHMM')],[ymax,0],'r-')
    %     end
    %
        
    ax(2)=subplot(4,1,1);
    plot(sort(match_time_keep),cumsum(ones(length(match_time_keep),1)),'lineWidth',2)
    % startDate = datenum('01-01-2005');
    % endDate = datenum('01-01-2014');
    xlim([startDate endDate])
    datetickJP('x','dd-mmm','keeplimits','keepticks')
    set(gca,'xminortick','on')
    ylabel('Cumulative Event Count','FontSize',12,'FontWeight','Bold')
    xlabel('Date Time','FontSize',12,'FontWeight','Bold')
    hold on, grid on, box on
    title((lab{sta}),'interpreter','none','FontSize',12,'FontWeight','Bold')
    %     for i=1:length(etimes)
    %         plot([datenum(int2str(etimes(i)),'yyyymmddHHMM'),datenum(int2str(etimes(i)),'yyyymmddHHMM')],[max(get(ax(2),'YLim')),0],'r-')
    %     end
    
    ax(1)=subplot(4,1,3);
    plot(match_time_keep,Ml_keep,'*')
    hold on, grid on, box on
    plot(match_time_best(find(match_time_best>0)),Ml_best_ind(find(match_time_best>0)),'ro','MarkerSize',8,'MarkerFaceColor','r','MarkerEdgeColor','k')
    plot(match_time_keep,cumMag(Ml_keep),'b')
    
    xlim([startDate endDate])
    ylim([floor(min(Ml)) ceil(max(Ml))])
    datetickJP('x','dd-mmm','keeplimits','keepticks')
    set(gca,'xminortick','on')
    ylabel('Relative Magnitude','FontSize',12,'FontWeight','Bold')
    xlabel('Date Time','FontSize',12,'FontWeight','Bold')
    legend('Matches','Template Event','Cum Mag','Location','Northwest')
    %     plot([datenum(2017,4,13,0,0,0),datenum(2017,4,13,0,0,0)],[ceil(max(Ml_keep)),0],'r-')
    %     for i=1:length(etimes)
    %         plot([datenum(int2str(etimes(i)),'yyyymmddHHMM'),datenum(int2str(etimes(i)),'yyyymmddHHMM')],[ceil(max(Ml_keep)),Mc],'r-')
    %     end
    %
    ax(3)=subplot(4,1,2);
    yyaxis right
    plot(match_time_keep,ncc_keep,'.k');
    ax(3).YColor = 'k';
    hold on
%     plot(match_time_best(find(match_time_best>0)),ncc_best_ind(find(match_time_best>0)),'ro','MarkerSize',8,'MarkerFaceColor','r','MarkerEdgeColor','k')
    ylabel('Normalized CCC','FontSize',12,'FontWeight','Bold')
    yyaxis left
    plot(match_time_keep,CC_keep,'*k')
    ax(3).YColor = 'k';
    plot(match_time_best(find(match_time_best>0)),CC_best_ind(find(match_time_best>0)),'ro','MarkerSize',8,'MarkerFaceColor','r','MarkerEdgeColor','k')
    xlim([startDate endDate])
    datetickJP('x','dd-mmm','keeplimits','keepticks')
    set(gca,'xminortick','on')
    xlabel('Date Time','FontSize',12,'FontWeight','Bold')
    ylabel('CCC','FontSize',12,'FontWeight','Bold')
    hold on, grid on, box on
    legend('Matches','Template Event','Location','Northwest')
    %     plot([datenum(2017,4,13,0,0,0),datenum(2017,4,13,0,0,0)],[ceil(max(ncc_keep)),0],'r-')
    %     for i=1:length(etimes)
    %         plot([datenum(int2str(etimes(i)),'yyyymmddHHMM'),datenum(int2str(etimes(i)),'yyyymmddHHMM')],[ceil(max(ncc_keep)),0],'r-')
    %     end
    %
    linkaxes(ax,'x')
    zoom XON
    
    print([outDir,filesep,lab{sta},'.png'],'-dpng')
    fclose(FID_results);
    %%Plot Waveforms for all matches.
    
    %     Ml_Filt=filtered_matches(Ml_keep_ind);
    %     c=correlation(Ml_Filt);
    %     figure,plot(c,'wig')
    %     title(lab{1},'interpreter','none')
    %     print([lab{1},'_wig'],'-dpng')
    %
    %     c=correlation(filtered_matches(Ml_keep_ind));
    %     figure
    %     c = xcorr(c,[0 30]);
    %     c = adjusttrig(c,'MIN',5);
    %     c = xcorr(c,[8 14]);
    %     c = adjusttrig(c,'LSQ',2);
    %     plot(c,'wig')
    
end
%% make catalog obj
for i=1:length(match_time_keep)
    otime(i) = match_time_keep(i);
    ontime(i)=otime(i);
    offtime(i)=otime(i)+datenum(0,0,0,0,0,25);
end
cobj = Catalog('otime',otime,'ontime',ontime,'offtime',offtime);

%% plot helicorders (this is slow, downsample?). only using first station
for day=startDate:endDate
    
    I = otime>day & otime<=day+1;
    if sum(I)>0
        w=load_waveformObject_VDAP(ds,scnl(1),day,day+1,40);
%         w = waveform(ds,scnl,day,day+1);
        w = fillgaps(w, 'interp');
        w = detrend(w);
        w = filtfilt(f, w);
        % make a drumplot object. mpl means minutes per line and is set here to 5.
        %     h2 = drumplot(w, 'mpl', 30);
        %     % plot the drumplot object - many events are visible, this is an earthquake
        %     plot(h2)
        %% Plot detected events on top of the continuous drumplot
        h3 = drumplot(w, 'mpl', 30, 'catalog', cobj);
        plot(h3)
        print(gcf,fullfile(outDir,'NMF',[datestr(day,'yyyymmdd'),'drum']),'-dpng')
    end
    
end

%{
c=correlation(filtered_matches(Ml_keep_ind));
figure
c = xcorr(c,[0 30]);
c = adjusttrig(c,'MIN',5);
c = xcorr(c,[8 14]);
c = adjusttrig(c,'LSQ',2);
plot(c,'wig')
%}

% end