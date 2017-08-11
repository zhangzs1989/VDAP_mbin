%%% RUN

run('~/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/UnitedStates_explosions_params.m')

%%% volcanoes

load('~/Documents/MATLAB/VDAP_mbin/dataseries/US_volcano_list.mat')
% test_volcanoes = {'St. Helens', 'Hood', 'Rainier', 'Baker', 'Adams', 'Newberry', ...
%     'Spurr', 'Redoubt', 'Kasatochi', 'Kanaga', 'Augustine', ...
%     'Cleveland', 'Veniaminof', 'Pavlof', ...
%     'Kilauea', 'Mauna Loa', 'Mauna Kea'}; % ALL
test_volcanoes = {...
    'Spurr', 'Redoubt', 'Kasatochi', 'Kanaga', 'Augustine', ...
    'Veniaminof', 'Pavlof', 'St. Helens', 'Shishaldin', 'Okmok', ...
    }; % US Monitored stratovolcano eruptions
% test_volcanoes = {...
%     'Spurr', 'Redoubt', 'Augustine', ...
%     'Veniaminof', 'Pavlof', 'St. Helens', ...
%     }; % SSA examples
% test_volcanoes = {'Redoubt'}; % other
volcanoes = volcano_list(ismember(volcano_list.name, test_volcanoes), :)

% eruptions - study subset
% all_eruptions = rdGVPeruptions('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/EFIS/GVP/GVP_eruptions.csv');
% eruptions = all_eruptions(contains(all_eruptions.volcano, volcanoes.name) & all_eruptions.start_date > study_start & contains(all_eruptions.activity_type, 'Confirmed Eruption'), :)


%% load catalog

disp('Reading catalog(s)...')
% This is the ANSS catalog for Hawaii, CONUS, and Alaska
load('~/Documents/MATLAB/VDAP_mbin/dataseries/master_catalog.mat')
disp(['...' num2str(height(master_catalog)) ' event(s) read.'])

%%

LOG = [];

for v = 1:height(volcanoes)
    
    % save short variable names for volcano name and id# (id# could be
    % volcano id or any other unique ID assignment)
    vname = volcanoes.name{v};
    id = volcanoes.id{v};
    
    clear eqt eqMo
    
    disp(['Running analysis for ' vname '...'])
    log = cell2table(allcomb({vname}, ...
        catalog_background_time, annulus, maxdepth, minmag, ...
        t_window, emp_threshold, include_intraeruption, use_triggers), ...
        'VariableNames', ...
        {'volcano_name', ...
        'catalog_background_time', 'annulus', 'maxdepth', 'minmag'...
        't_window', 'conf_level', 'include_intraeruption', 'use_triggers'});
    log = unique(log); % this line shouldn't be necessary! Why isn't ALLCOMB working?
    
    % get eruption start/stop dates (Ess) for this volcano
    % create ERUPTION objects
    clear E e   
    fname = (fullfile(explosions_data.dir, vname, 'explosions_table.mat'));
    if exist(fname, 'file')
        load(fname)
        Ess = [explosions.start explosions.stop];
        Ess(isnat(Ess(:,1)), 1) = Ess(isnat(Ess(:,1)), 2); % ensure that there are no NaT values in Ess
        %         vei = repmat(1, size(Ess,1), 1); % stub bc there is no vei info for these events
        vei = ones(1, size(Ess,1), 1); % stub bc there is no vei info for these events - Matlab's suggestion for readability (delete preceding line once things are running smoothily)
        for e = 1:size(Ess,1), E(e) = ERUPTION; E(e).start = Ess(e,1); E(e).stop = Ess(e,2); E(e).max_vei = vei(e); end
    else
        E(1) = ERUPTION;
    end
    
    
    for l = 1:height(log)
        
        disp(' ')
        disp(log(l,:))
        
        %%% Filtering Catalog
%         disp('Filtering catalog...')
        catalog = master_catalog;
        
        % filter by depth
        catalog = catalog(catalog.Depth <= log.maxdepth(l), :);
        
        % filter by annulus
        catalog.dkm = deg2km(...
            distance(volcanoes(v,:).lat, volcanoes(v,:).lon, ...
            catalog.Latitude, catalog.Longitude));
        catalog = catalog( catalog.dkm >= log.annulus(l,1) & catalog.dkm <= log.annulus(l,2), : );
        catalog.dkm = [];
        
        % filter by magnitude
        catalog = catalog(catalog.Magnitude >= log.minmag(l), :);

        % Incorporate a trigger file, if desired
        if log.use_triggers(l)
            trigger_file = fullfile(explosions_data.dir, vname, 'trigger.mat');
            if exist(trigger_file, 'file')
                load(trigger_file); % loads Variable 'trigger'
                catalog = [catalog; trigger];
                catalog = sortrows(catalog, 'DateTime');
            else
                disp('Trigger file was requested, but no file was available.')
            end
        else
            % do nothing
        end
        
        % filter by event type
        %%% not currently an option
        
        % extract variables
        eqt = datenum(catalog.DateTime);
        eqMo = magnitude2moment(catalog.Magnitude); eqMo(isnan(eqMo)) = 0;
        eqDepth = catalog.Depth;
        eqLat = catalog.Latitude;
        eqLon = catalog.Longitude;
        %         eqType = catalog.Type;
        
        % report stats on catalog
        
        disp(['    ...' num2str(numel(eqt)) ' event(s) in filtered catalog'])
        disp('        *This includes intraeruptive time periods')
        a = sum(~isnan(catalog.Latitude));
        b = sum(~strcmpi(catalog.Type, ''));
        disp(['        (' num2str(round( a / height(catalog) * 100 )) '% located)'])
        disp(['        (' num2str(round( b / height(catalog) * 100 )) '% classified by type)'])
        disp(['        (' num2str(round( (a && b) / height(catalog) * 100 )) '% classified by type and located)'])
        %%% Done filtering Catalog
        
        % if you want to include intra_explosive seismicity, do NOT use INTERINTERVAL
        % if you want to exlude intra-explosive seismicity, use INTERINTERVAL
        if log.include_intraeruption(l)
            background_time = log(l,:).catalog_background_time;
        else
            background_time = interinterval(Ess, log(l,:).catalog_background_time(1), log(l,:).catalog_background_time(2));
        end
        

        %%% Conduct Analysis
        DATA = ps2ts(eqt, eqMo, background_time, log(l, :).t_window(1), log(l,:).t_window(2));
        
        % Add beta values to 'BETA'
        a = datenum(background_time);
        BETA.N = sum(sum( (eqt'>=a(:,1)) .* (eqt'<a(:,2)) )); % total # of eqs in entire study period
        BETA.T = sum(a(:,2)-a(:,1)); % Total amount of time in entire study period
        BETA.bv = betas(DATA.binCounts, BETA.N, log(l,:).t_window(2), BETA.T);
        BETA.be = empiricalbeta(DATA.tc, BETA.bv, background_time, log(l, :).conf_level);
        
        % Add eruptions to 'DATA'
        DATA.E = E;
        DATA.CAT = table(eqt, eqLat, eqLon, eqDepth, magnitude2moment(eqMo, 'reverse')', 'VariableNames', ...
            {'DateTime', 'Latitude', 'Longitude', 'Depth', 'Magnitude'});
                
        %%% Save to LOG
        LOG = [LOG; [log(l,:) table(DATA) table(BETA)]];
        
    end
    
end
LOG
save('/Users/jjw2/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/LOG.mat', 'LOG')

%%

% dataseries_plot4_forExplosions
% dataseries_pd_plot3
% dataseries_CatalogTrigger_plot1
% run_AKtriggered_routines
inquiry1
