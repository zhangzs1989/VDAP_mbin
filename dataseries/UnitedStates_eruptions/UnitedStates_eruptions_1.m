%%%
run('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/UnitedStates_eruptions_params.m')

%%% volcanoes

load('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/US_volcano_list.mat')
test_volcanoes = {'St. Helens', 'Hood', 'Rainier', 'Baker', 'Adams', 'Newberry', ...
    'Spurr', 'Redoubt', 'Kasatochi', 'Kanaga', 'Augustine', ...
    'Cleveland', 'Veniaminof', 'Pavlof', ...
    'Kilauea', 'Mauna Loa', 'Mauna Kea'};
test_volcanoes = {'Iliamna'}
volcanoes = volcano_list(ismember(volcano_list.name, test_volcanoes), :)

% eruptions - study subset
all_eruptions = rdGVPeruptions('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/EFIS/GVP/GVP_eruptions.csv');
eruptions = all_eruptions(contains(all_eruptions.volcano, volcanoes.name) & all_eruptions.start_date > study_start & contains(all_eruptions.activity_type, 'Confirmed Eruption'), :)


%% load catalog

disp('Reading catalog(s)...')
% This is the ANSS catalog for Hawaii, CONUS, and Alaska
load('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/master_catalog.mat')
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
        t_window, emp_threshold), ...
        'VariableNames', ...
        {'volcano_name', ...
        'catalog_background_time', 'annulus', 'maxdepth', 'minmag'...
        't_window', 'conf_level'});
    log = unique(log); % this line shouldn't be necessary! Why isn't ALLCOMB working?
    
    % get eruption start/stop dates (Ess) for this volcano
    clear E e
    Ess = eruptions{strcmpi(eruptions.volcano, volcanoes.name{v}), {'start_date', 'end_date'}};
    Ess(isnat(Ess(:,1)), 1) = Ess(isnat(Ess(:,1)), 2); % ensure that there are no NaT values in Ess
    vei = eruptions{strcmpi(eruptions.volcano, volcanoes.name{v}), {'VEIMax'}};
    for e = 1:size(Ess,1), E(e) = ERUPTION; E(e).start = Ess(e,1); E(e).stop = Ess(e,2); E(e).max_vei = vei(e); end
    if isempty(Ess), E(1) = ERUPTION; end
    
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
        
        % filter by magnitude
        catalog = catalog(catalog.Magnitude >= log.minmag(l), :);
        
        eqt = datenum(catalog.DateTime);
        eqMo = magnitude2moment(catalog.Magnitude); eqMo(isnan(eqMo)) = 0;
        eqDepth = catalog.Depth;
        eqLat = catalog.Latitude;
        eqLon = catalog.Longitude;
        
        disp(['    ...' num2str(numel(eqt)) ' event(s) in filtered catalog'])
        %%% Done filtering Catalog
        
        background_time = interinterval(Ess, log(l,:).catalog_background_time(1), log(l,:).catalog_background_time(2));
        
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
        DATA.CAT = table(eqt, eqLat, eqLon, eqDepth, magnitude2moment(eqMo, 'reverse'), 'VariableNames', ...
            {'DateTime', 'Latitude', 'Longitude', 'Depth', 'Magnitude'});
        
        % Add Seismic Anomalies to 'SANOM'
        % start stop | start_stop
        % duration_days
        % duration_bins
        % be_rat
        
        % Anomaly Type
        % append 'Tp' 'Ta' 'Tr' to LOG
        % use this info to add SANOM.type
        
        %%% Save to LOG
        LOG = [LOG; [log(l,:) table(DATA) table(BETA)]];
        
    end
    
end
LOG

%%

% seismicTSpd_plot1
dataseries_plot4_forExplosions