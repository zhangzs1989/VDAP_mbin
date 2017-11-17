function plotNMFresults(inputs,params)

%TODO: color different templates and matched differently

t_pre = 0;
t_post= 10;
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

templateFile=fullfile(baseDir,'templates/',[params.strRunName,'_OTs_NEICformat.txt']); %JP
templates = readtext(templateFile);
templateFile2=fullfile(baseDir,'templates/',[params.strRunName,'_NMFtemplateFile.txt']); %JP
templates2 = readtext(templateFile2,' ','','','textual');

for i=1:size(templates2,1)
    scnl(i)=scnlobject(templates2(i,5),templates2(i,6),templates2(i,4),templates2(i,7));
    CT(i) = ChannelTag(get(scnl(i),'network'),get(scnl(i),'station'),get(scnl(i),'location'),get(scnl(i),'channel'));
end
uCTs = unique(CT);
nsta = length(uCTs);

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
 
            matches1=load_waveformObject_VDAP(ds,scnl(sta),match_time(count),match_time(count)+datenum(0,0,0,0,0,t_post),40);
            matches1=align(matches1,match_time(count),get(matches1,'freq'));
            
            filtered_matches1=filtfilt(f,matches1);
            waveform_output=get(filtered_matches1,'DATA');
            amplitude(count)=max(abs(waveform_output));
            
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
    
    %TODO: pull rsam from wws and plot here
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
    dfac = 1;

    ax(2)=subplot(4,1,1);
    yyaxis left
    plot(sort(match_time_keep),cumsum(ones(length(match_time_keep),1)),'lineWidth',2)
    ylabel('Cumulative Event Count','FontSize',12,'FontWeight','Bold')
    c = ax(2).YColor;
    ax(2).YColor = 'k';
    ax(2).YLabel.Color = c;
    
    xlim([startDate endDate])
    datetickJP('x','dd-mmm','keeplimits','keepticks')
    set(gca,'xminortick','on')
    xlabel('Date Time','FontSize',12,'FontWeight','Bold')
    hold on, grid on, box on
    title((lab{sta}),'interpreter','none','FontSize',12,'FontWeight','Bold')
    yyaxis right
    h=histogram(match_time_keep,floor(min(match_time_keep)):dfac:ceil(max(match_time_keep)));
    h.FaceColor = 'none';
    ylabel('Event Count','FontWeight','bold','FontSize',12)
    ax(2).YColor = 'k';
    
    ax(1)=subplot(4,1,3);
    plot(match_time_keep,Ml_keep,'*')
    hold on, grid on, box on
    plot(match_time_best(match_time_best>0),Ml_best_ind(match_time_best>0),'ro','MarkerSize',8,'MarkerFaceColor','r','MarkerEdgeColor','k')
    plot(match_time_keep,cumMag(Ml_keep),'lineWidth',2)
    
    xlim([startDate endDate])
%     ylim([floor(min(Ml)) ceil(max(Ml))])
    datetickJP('x','dd-mmm','keeplimits','keepticks')
    set(gca,'xminortick','on')
    ylabel('Relative Magnitude','FontSize',12,'FontWeight','Bold')
    xlabel('Date Time','FontSize',12,'FontWeight','Bold')
    legend('Matches','Templates','Cum Mag','Location','Northwest')

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

    linkaxes(ax,'x')
    zoom XON
    
    print([outDir,filesep,lab{sta},'.png'],'-dpng')
    fclose(FID_results);
end