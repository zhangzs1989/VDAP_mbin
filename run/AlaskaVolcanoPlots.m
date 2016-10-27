function AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)

    % set up diary to record actions of AlaskaVolcanoPlots
diaryFileName = [params.outDir,filesep,vinfo.name,filesep,vinfo.name,'_',datestr(now,30),'_diary.txt'];
[~,~,~] = mkdir([params.outDir,filesep,vinfo.name]);
diary(diaryFileName);

    % Print information about this run to Command Windos
disp('-------------------------------------------------------------------')
disp('-------------------------------------------------------------------')
disp(vinfo.name)
disp(' ')
disp('-------------------------------------------------------------------')
disp('-- Input files used for this run ----------------------------------')
disp(inputFiles)
disp('-------------------------------------------------------------------')
disp(' ')
disp('-------------------------------------------------------------------')
disp('-- Parameters used for this run -----------------------------------')
disp(params)
disp('Other volcanoes analyzed in conjunction with this run:')
disp(params.volcanoes)
disp('-------------------------------------------------------------------')
disp(' ')

if size(catalog,2)==0
    error('No events in catalog')
end

if isempty(eruption_windows)
    disp('No eruption windows!')
    %return
end

%% filter catalog

[ catalog_b, outer, inner] = filterAnnulusm(catalog, vinfo.lat, vinfo.lon, params.srad); % filter annulus
% [ catalog_b ] = filterDepth( catalog_b, params.max_depth_threshold ); % (d)
[ catalog_b ] = filterMag( catalog_b, eruption_windows(1,4) ); % (e) % now assume Mc is the same for all eruptions
% [ catalog_b ] = filterTime( catalog_b, datenum('1990/01/01'), datenum('2016/05/01'));
% catalog_AV = filterByNetworkCode( catalog_b, {'AV'} ); % (c)

volc_times = datenum(extractfield(catalog,'DateTime'));

%% TEMP bad data actions

% need to just update master file once, once we decide what to do.  Until
% then:

% this should have been the solution, but I don't trust it
% baddata = getBadDataFromHelena2(vinfo.name, [min(volc_times) max(volc_times)]); % (a)

%INSTEAD,
% get downdays for 2002 - 2012 from HB's manually groomed study
[baddata1,vinfo.NetworkStartDay] = getBadDataFromHelena(vinfo.volcname, [min(volc_times) max(volc_times)],inputFiles.HB); % (a)

% now get downdays from 2013-2015 from JP's new data, eventually update all
% years this way?? too much trouble
baddata2 = getVolcanoNetworkDownDays(vinfo.volcname, [min(volc_times) max(volc_times)],params,inputFiles); % (a)

% now cat them together for temp fix until we redo the whole thing
% ourselves
try
    baddata = [baddata1; baddata2];
catch
    baddata = [baddata1'; baddata2];
end
stats(1,:) = {'volcano','startDay','#downDays','#upDays'};
stats(2,1) = {vinfo.name};
stats(2,3) = {numel(baddata)};
stats(2,2) = {datestr(vinfo.NetworkStartDay)};
stats(2,4) = {datenum(2016,1,1,0,0,0)-vinfo.NetworkStartDay-numel(baddata)};
for i=1:length(baddata)
    spout(i,1)={datestr(baddata(i))};
end  
try
    s6_cellwrite(fullfile(params.outDir,vinfo.name,filesep,[vinfo.name,'NetworkDownDays.csv']),spout);
catch
    warning('No baddata found')
end
s6_cellwrite(fullfile(params.outDir,vinfo.name,filesep,[vinfo.name,'NetworkStats.csv']),stats);

% baddata = baddata1; % temp while running badger...

%% Display catalog data
% disp('-------------------------------------------------------------------')
% disp('-- Subset of ANSS catalog -----------------------------------------')
% fprintf('     %i of %i catalog events within %ikm of the volcano', length(catalog_b), length(catalog), params.srad);
% sprintf('     min mag = ' num2str(min(extractfield(catalog,'Magnitude')))]);
% disp(['max mag = ' num2str(max(extractfield(catalog,'Magnitude')))]);
% disp('-------------------------------------------------------------------')

fprintf('----------------------------------------------------------------\n')
fprintf('  Subset of ANSS catalog                                        \n')
fprintf('                   Imported Catalog |           Volcano Subset  \n')
fprintf('   # events |  %20i |     %20i \n', ...
    length(catalog), length(catalog_b))
fprintf('   Max Mag  |  %20.1f |     %20.1f \n', ...
    max(extractfield(catalog,'Magnitude')), ...
    max(extractfield(catalog_b,'Magnitude')))
fprintf('   Min Mag  |  %20.1f |     %20.1f \n', ...
    min(extractfield(catalog,'Magnitude')), ...
    min(extractfield(catalog_b,'Magnitude')))
fprintf('----------------------------------------------------------------\n')
disp(' ')

%% beta swarm plots
if params.doBeta 
[~] = prepAndDoBetas(vinfo,eruption_windows,params,inputFiles,catalog_b,baddata);
end

%% Wing plot
if params.wingPlot
    
    % prep plot windows
    plot_windows=[];
    plot_names=[];
    
    % plot whole catalog
    t1 = datenum(catalog(1).DateTime);
    t2 = datenum(catalog(end).DateTime);
    str = 'all';
    
    plot_windows = [plot_windows; t1 t2];
    plot_names=[plot_names,{str}];
    if isstr(params.volcanoes) && strcmp(params.volcanoes,'NoErupt') || isempty(eruption_windows)
        [~] = prepAndDoWingPlot(vinfo,params,inputFiles,catalog_b,outer,inner,plot_windows,plot_names);
    end
    
    %plot eruption windows, with pre eruption time
    for i=1:size(eruption_windows,1)

        t1 = eruption_windows(i,1) - params.AnomSearchWindow;
        t2 = eruption_windows(i,1); % stop at start of eruption
        str = int2str(i);
        plot_windows = [plot_windows; t1 t2];
        plot_names=[plot_names,{str}];
        
    end
    
    if ~isempty(eruption_windows)
        % plot activity since last eruption
        t1 = max(max(eruption_windows));
        t2 = datenum(params.catalogEndDate);
        str = 'recent';
        plot_windows = [plot_windows; t1 t2];
        plot_names=[plot_names,{str}];
        
        [~] = prepAndDoWingPlot(vinfo,params,inputFiles,catalog_b,outer,inner,plot_windows,plot_names);
    end
end

%% 
if params.jiggle

%     nDaysQC = 7; % number of consecutive days over which there must be no triggers in order to consider network down
%     [~,baddata,~,~] = getNetworkOffDaysFromJiggle(jiggle,volcname,min(volcAV_times),max(volc_times),nDaysQC);
    catalog_j = prepJiggleCatalog(vinfo.name,jiggle);
    if isempty(catalog_j)
        warning(['No triggers in jiggle for volcano: ',volcname])
    else
        [~] = prepAndDoBetas(vinfo,eruption_windows,params,inputFiles,catalog_j,baddata);
    end
end

diary OFF

end