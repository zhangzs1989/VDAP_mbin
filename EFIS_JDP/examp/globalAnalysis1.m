% import eruption and event data and plot it
%
% J. PESICEK Winter 2016

clearvars -except catalog

%% inputs
[input,params] = getInputFiles('inputFiles.txt');

%% set up diary to record actions of AlaskaVolcanoPlots
[~,~,~] = mkdir([params.outDir]);
diaryFileName = [params.outDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);

%% read in GVP data
load(input.EFIS_eruptions); % eruptionCat struct imported via importEruptionCatalog.m from OGBURN FILE
[eruptionCat,vinfo] = filterEruptions(eruptionCat,input,params);

%% LOAD catalog
if ~exist('catalog','var')
    disp('loading catalog...')
    load(input.catalog); %created using importISCcatalog.m
    % define preliminary filtering here, and do only once
    %     [ catalog ] = filterDepth( catalog, params.max_depth_threshold ); % (d)
    %     [ catalog ] = filterMag( catalog, params.min_mag ); % (e)
    %     [ catalog ] = filterTime( catalog, datenum('1990/01/01'), params.catalogEndDate); % start here to cut out redoubt for now
    catalog = regionalCatalogFilter(input,catalog);
    disp('...catalog loaded')
    disp([int2str(size(catalog,1)),' earthquakes remaining'])
else
    disp('WARNING: using previously loaded (and filtered?) catalog')
end

%% loop over eruptions
for i=1:size(eruptionCat,1)
    
    [einfo, vinfo] = getEruptionInfo(eruptionCat,vinfo,i);
    [ catalog_v, outer, inner] = filterAnnulusm(catalog, vinfo.lat, vinfo.lon, params.srad); % filter annulus
    
    %% Wing plot
    t1 = datestr(datenum(einfo.date) - params.ndaysBeforeEruptionStart); %plot start time
    t1 = datenum(t1);
    t2 = datenum(einfo.date)+params.ndaysAfterEruptionStart; %plot end time
    str = datestr(datenum(einfo.date),'yyyymmdd');
    [~] = prepAndDoWingPlot(vinfo,params,input,catalog_v,outer,inner,[t1 t2],str);
    
end
%% loop over volcanoes and plot all eqs in catalog
str = 'all';
for i=1:size(eruptionCat,1)
    %     ii = i+1;
    
    vinfo.name = extractfield(eruptionCat(i),'Volcano');
    disp([vinfo.name,', all'])
    I = find(strcmp(extractfield(eruptionCat,'Volcano'),vinfo.name),1);
    [~, vinfo] = getEruptionInfo(eruptionCat,vinfo,I);
    
    [ catalog_v, outer, inner] = filterAnnulusm(catalog, vinfo.lat, vinfo.lon, params.srad); % filter annulus
    
    t1 = catalog(1).DateTime;
    t2 = catalog(end).DateTime;
    %     t2 = datestr(datenum(catalog_v(end).DateTime)+datenum(0,0,0,1,0,0));% add an hour for color plotting of one event
    
    [~] = prepAndDoWingPlot(vinfo,params,input,catalog_v,outer,inner,[datenum(t1) datenum(t2)],str);
end
diary OFF

