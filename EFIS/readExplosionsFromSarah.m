%% importExplosionsFromSarah - Alaska

file = '/Users/jaywellik/Documents/MATLAB/VDAP_mbin/EFIS/fromSarah/alaska_explosions_v4.xlsx';
formatSpec = '%* %s %s %s %s %s %{MM/dd/yyyy}D %{HH:mm:ss}D %* %* %* %f %{MM/dd/yyyy}D %{HH:mm:ss}D %* %* %* %f %d %f %f';
var_names = {'vid', 'eruption_id', 'exp_id', 'event_name', 'exp_type', 'start_date', 'start_time', 'start_error', 'end_date', 'end_time', 'end_error', 'vei', 'vol', 'colh'};
T = tablescan(file, formatSpec, var_names, 'Delimiter', ',', 'HeaderLines', 1)

%% Print explosions volcano by volcano

clc

load('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/volcano_list.mat')
test_volcanoes = {...
    'Spurr', 'Redoubt', 'Kasatochi', 'Kanaga', 'Augustine', ...
    'Cleveland', 'Veniaminof', 'Pavlof'};
volcanoes = volcano_list(ismember(volcano_list.name, test_volcanoes), :)

T_AK = T(ismember(T.vid, volcanoes.id), :)
for n = 1:height(volcanoes), display(volcanoes.name{n}), T(ismember(T.vid, volcanoes.id{n}), :), end