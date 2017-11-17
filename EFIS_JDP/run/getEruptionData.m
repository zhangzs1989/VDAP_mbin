function eruptionData = getEruptionData(input,params)

%% collect Eruption Data from catalog database

%% READ inputs
% [input,params] = getInputFiles(InputFileName);

%% set up diary
[~,~,~] = mkdir([input.outDir]);
diaryFileName = [input.outDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')
disp(params)

%% read in GVP data
load(input.gvp_volcanoes); % spits out eruptionCat
load(input.gvp_eruptions); % spits out volcanoCat
[eruptionCat,vinfo] = filterEruptions(eruptionCat,volcanoCat,input,params);

%% loop over eruptions
volcname0 = [];
for i=1:size(eruptionCat,1)
    
    disp([int2str(i),'/',int2str(size(eruptionCat,1))])
    
    % get eruption info
    einfo = getEruptionInfo(eruptionCat,i);
    vinfo = getVolcanoInfoFromNameOrNum(einfo.Vnum,volcanoCat);
    str = datestr(datenum(einfo.StartDate),'yyyymmdd');
    
    %% get Mc
    t1 = datenum(einfo.StartDate)-params.daysBeforeEruption;
    t2 = datenum(einfo.StartDate)-2;% Mc at Rabual shoots up near eruption
    McInfo = grabMcInWindow(t1,t2,vinfo,input.catalogsDir);
%     H = mkMcFig(McInfo,'on');

    %% %load catalogs
    volcname  = fixStringName(eruptionCat(i).volcano);
    cFileName = sprintf('MASTER_%d.mat',eruptionCat(i).Vnum);
    
    if ~strcmp(volcname,volcname0) % skip when same volcano, assumes sorted by volcano
        
        try
            load(fullfile(input.catalogsDir,fixStringName(vinfo.country),volcname,cFileName));
        catch %% because non-unique volcano names have ID after
            load(fullfile(input.catalogsDir,fixStringName(vinfo.country),[volcname,int2str(vinfo.Vnum)],cFileName));
        end
        volcname0=volcname;
        
        % filter by radius
        [catalog , outer_ann, inner_ann]= filterAnnulusm(catalog,vinfo.lat,vinfo.lon,params.srad);
        catalog = filterDepth( catalog, params.DepthRange );
        catalog = filterMag(catalog,params.MagRange);
        if params.wingPlot
            mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
        end
    end
    
    % NOTE: GVP has no eruption times, only dates!!
    % Thus, ASSUME that if an event is on the day of the eruption, that it
    % is a precursor to the eruption. Only count it once as preEruptive,
    % not also synEruptive
    
    % filter catalog by time before
    t1 = datestr(datenum(einfo.StartDate) - params.daysBeforeEruption); %plot start time
    t1 = datenum(t1);
    t2 = datenum(einfo.StartDate)+params.daysAfterEruption; %thus including whole day of eruption
    catalog_t = filterTime(catalog,t1,t2);
    
    %%
    % filter catalog by time during
    t1b = datenum(einfo.StartDate)+params.daysAfterEruption; % thus starting ndays after eruption (1)
    t2b = datenum(einfo.EndDate); %plot end time
    if isempty(t2b) || isnan(t2b)
        warning('no eruption end date, assuming same as start date')
        t2b = t1b + 1;
    end
    catalog_td = filterTime(catalog,t1b,t2b);
    %% add all fields to output line
    fn = fieldnames(vinfo);
    for ii=1:numel(fn)
        eruptionData(i).(fn{ii}) = vinfo.(fn{ii});
    end
    fn = fieldnames(einfo);
    for ii=1:numel(fn)
        eruptionData(i).(fn{ii}) = einfo.(fn{ii});
    end
    fn = fieldnames(McInfo);
    for ii=1:numel(fn)
        eruptionData(i).(fn{ii}) = McInfo.(fn{ii});
    end
    
    eruptionData(i).preCat = catalog_t;
    eruptionData(i).preCount = numel(catalog_t);
    eruptionData(i).synCat = catalog_td;
    eruptionData(i).synCount = numel(catalog_td);
    %% get CMM
    if isempty(catalog_t)
        cmag = 0; % NaN or zero??
    else
        [cmag,~] = cumMag(extractfield(catalog_t,'Magnitude'));
    end
    eruptionData(i).preCumMag = cmag(end);
    
    if isempty(catalog_td)
        cmag = NaN;
    else
        [cmag,~] = cumMag(extractfield(catalog_td,'Magnitude'));
    end
    eruptionData(i).synCumMag = cmag(end);
    
    %% Now do Wing plot
    if params.wingPlot && numel(catalog_t)>0
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog_t, mapdata, params,1);
        volcOutName = fixStringName(vinfo.name);
        print(fh_wingplot,'-dpng',[input.outDir,filesep,volcOutName,'_',str])
    end
end
%%
% if isfield(input,'outFileName')
%     aFileName = input.outFileName;
% else
%     aFileName=fullfile(input.outDir,'eruptionData');
% % end
% % % save([aFileName],'eruptionData','-struct')
% save(aFileName,'eruptionData')

diary OFF

end