%% Read a file of Arrival Time data downloaded from the JMA website
%%% This is for the nation-wide tectonic catalog

% Change FOLDER_LOCATION to the parent directory of VDAP_mbin
folder_location = '/Users/jaywellik/Documents/MATLAB';
testfile = '/VDAP_mbin/NIED_JMA_tools/Tutorials/measure_20170101.txt';
filename = fullfile(folder_location, testfile);

events = rdarrivaltimes(filename);

%% Download and read JMA volcanic earthquake counts

% % downloadveq('2007/12','2008/02') % this is the old way
% JMA.download('EV', '2007/12','2008/02','/Users/jaywellik/Documents/JMADATA/veq/'); % this is the new way

files = ls('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/NIED_JMA_tools/Tutorials/data/En*.csv');
files = strsplit(files); files(end) = [];
V = JMAVEQ.rdveq(files);
V = combinevolcano(V);
for n = 1:numel(V); plot(V(n)); saveas(gcf, [V(n).VN '_timeseries.png']); end

%% Download and Read JMA Visual Observation Data

% JMA.download('V', '2002/01', '2014/02', '/Users/jaywellik/Documents/JMADATA/enbo/');

files = ls('/Users/jaywellik/Documents/JMADATA/enbo/V*.csv');
files = strsplit(files); files(end) = [];
VIS = JMAVIS.rdvisobs(files);


gvp_volcanoes = rdGVPvolcano('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/EFIS/GVP/GVP_volcanoes.csv');
jp_volcanoes = gvp_volcanoes(strcmpi(gvp_volcanoes.country, 'Japan'), :);
jma_alt = readtable('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/NIED_JMA_tools/@JMA/JMA_volc_alt_name.txt', 'Format', '%s%s%s%s');
hm = [hashmap(jp_volcanoes, 'volc_alt_name'); jma_alt];
[vid, vnum, off_name] = assignGVPID(jp_volcanoes, get(VIS, 'VN'));
VIS = set(VIS, 'VID', vid); % assign the VID to the JMAVIS object
VIS = set(VIS, 'VN', off_name); % change the volcnao name in the JMAVIS object

VIS = combinevolcano(VIS, 'VID');
VIS = write(VIS, '/Users/jaywellik/Dropbox/JAY-VDAP/Japan/enbo_raw/');
VIS = rmnullreports(VIS);
VIS = write(VIS, '/Users/jaywellik/Dropbox/JAY-VDAP/Japan/enbo/');

for n = 1:numel(VIS)
    plotts_dev(VIS(n))
    saveas(gcf, fullfile('/Users/jaywellik/Dropbox/JAY-VDAP/Japan/Column_TS_images', [VIS(n).VN '.png']))
    clf
end


%% Download and Read JMA Earthquake Catalogs

files = ls('/Users/jaywellik/Documents/JMADATA/obs/Eo*.csv');
files = strsplit(files); files(end) = [];
VCAT = JMA.readfile(files);

gvp_volcanoes = rdGVPvolcano('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/EFIS/GVP/GVP_volcanoes.csv');
jp_volcanoes = gvp_volcanoes(strcmpi(gvp_volcanoes.country, 'Japan'), :);
jma_alt = readtable('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/NIED_JMA_tools/@JMA/JMA_volc_alt_name.txt', 'Format', '%s%s%s%s');
hm = [hashmap(jp_volcanoes, 'volc_alt_name'); jma_alt];
[vid, vnum, off_name] = assignGVPID(jp_volcanoes, get(VCAT, 'VN'));
VCAT = set(VCAT, 'VID', vid); % assign the VID to the JMAVIS object
VCAT = set(VCAT, 'VN', off_name); % change the volcnao name in the JMAVIS object

VCAT = combinevolcano(VCAT, 'VID');
