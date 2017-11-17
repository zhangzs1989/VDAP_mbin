function catalog_big = getVolcanoData(input,params)

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
load(input.gvp_volcanoes); % eruptionCat struct imported via importEruptionCatalog.m from OGBURN FILE
load(input.gvp_eruptions);
[volcanoCat,~] = filterVolcanoes(volcanoCat,input,params);

%% loop over volcanoes
catalog_big = struct([]);
veq = 0;
for i=1:size(volcanoCat,1)
    
    %load catalog
    volcname  = fixStringName(volcanoCat(i).Volcano);
    cFileName = sprintf('MASTER_%d.mat',volcanoCat(i).Vnum);
    load(fullfile(input.catalogsDir,fixStringName(volcanoCat(i).country),volcname,cFileName));
    disp([int2str(i),'/',int2str(size(volcanoCat,1)),', ',volcanoCat(i).Volcano,', ',int2str(numel(catalog)),' events'])
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    
    [ catalog,~,~] = filterAnnulusm(catalog, vinfo.lat, vinfo.lon, params.srad); % filter annulus
    catalog = filterTime(catalog,datenum(params.YearRange(1),1,1),datenum(params.YearRange(2)+1,1,1));
    catalog = filterMag(catalog,params.MagRange);
    catalog = filterDepth( catalog, params.DepthRange );
    disp([int2str(numel(catalog)),' events after filtering'])
    
    %     %get eruption dates
    ie = find(extractfield(eruptionCat,'Vnum')==vinfo.Vnum);
    disp([int2str(numel(ie)),' eruptions'])
    if isempty(ie)
        eruptStartDays = [];
        eruptStopDays = [];
    else
        eruptStartDays = extractfield(eruptionCat(ie),'StartDate');
        eruptStopDays = extractfield(eruptionCat(ie),'EndDate');
        
        if isempty(eruptStopDays)
            eruptStopDays = {eruptStopDays};
        end
        
        se = find(cellfun('isempty',eruptStopDays));
        for a=1:length(se)
            eruptStopDays(se(a)) = {datestr(datenum(eruptStartDays(se(a))) + 1)};
        end
    end
    
    %% NOTE remember that GVP only has eruption
    % date, not time!!
    for j=1:numel(catalog)
        veq = veq + 1;
        
        %% replace with getEruptionInfo4event some day
%         [ catalogb ] = getEruptionInfo4events(catalog(j),vinfo,eruptionCat,params.srad(2));
%         not ready for prime time yet
        %%
        eqtime = datenum(catalog(j).DateTime);
        dayLags = datenum(eruptStartDays)-floor(eqtime); % this makes eqs on eruption day to have zero lag.
        I = (eqtime <= datenum(eruptStopDays) & ceil(eqtime) > datenum(eruptStartDays)); %those during eruption
        si = sign(dayLags)>-1; % includes those events on eruption day
        [Y,~] = min(dayLags(si));
        
        if ~isempty(Y)
            ei = dayLags==Y;
            catalog_big(veq).EruptID = eruptionCat(ie(ei)).eruption_id;
            catalog_big(veq).DayLag = Y;
        else
            catalog_big(veq).EruptID = NaN;
            catalog_big(veq).DayLag = NaN;
        end
        catalog_big(veq).coEruptive = sum(I);
        catalog_big(veq).Latitude = catalog(j).Latitude;
        catalog_big(veq).Longitude = catalog(j).Longitude;
        catalog_big(veq).Depth = catalog(j).Depth;
        catalog_big(veq).Magnitude = catalog(j).Magnitude;
        catalog_big(veq).DateTime = catalog(j).DateTime;
        catalog_big(veq).AUTHOR = catalog(j).AUTHOR;
        catalog_big(veq).name = vinfo.name;
        catalog_big(veq).Vnum = vinfo.Vnum;
        
        catalog_big(veq).composition = vinfo.composition;
        catalog_big(veq).type = vinfo.type;
        catalog_big(veq).tectonic = vinfo.tectonic;
        [ARCLEN, AZ] = distance(catalog(j).Latitude,catalog(j).Longitude,vinfo.lat,vinfo.lon);
        catalog_big(veq).dist = deg2km(ARCLEN);
        catalog_big(veq).azi = AZ;
        catalog_big(veq).SHmax = vinfo.SHmax;
        
    end
    
    
end
%%
% save(fullfile(input.outDir,'catalog_big'),'catalog_big');
diary OFF

end