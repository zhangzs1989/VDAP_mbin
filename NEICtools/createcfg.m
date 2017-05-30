function createcfg( outfile, line_name, etime, lat, lon, depth, mag, magtype,...
    tag, pick, picktime, svd_indep, varargin)
%CREATECFG Creates configuration file for NEIC Subspace Detector
%
% >> createcfg( './myconfigfile.cfg', [], event_times, [], [], [], [], [],
% 'RC.KBUR..EHZ', [], [], 'svd', ...
% {'bandpass: 2.0 8.0 3'; 'start_stop: 2004/09/23-00:00:00.000 2004/10/14-23:59:59.999'...
% '% output_path: ./'});
%
% Eventual goal is that you can either provide all of the inputs or just
% some of them or provide a catalog object that has all of the info.
% For right now, for example, it would be useful to simply pass a datetime
% and a ChannelTag and let the rest of the cfg file be created. In order to
% accmplish that, it would be good if createcfg filled unspecified fields
% with default values.
%
% An incomplete list of examples for the varargin:
% bandpass: 2.0 8.0 3
% sample_rate: 100
% start_stop: 2004/09/23-00:00:00.000 2004/10/14-23:59:59.999
% acquisition_parameters: 120 10 600
% inputcwb: localhost 2061
% detectionthreshold_parameters: 0.65 1800.0 9.0 constant
% template_parameters: 600.0 5.0 5.0 -0.1
% output_path: ./
% station_coordinates: 46.17428 -122.18065 1720.0
% centroid_location: 46.1743 -122.1806 1.0
% source_receiver_distance: 0.0043223067
% radial_distance: 10.0
% channels: EHZ 
% location_code: --
% waveform_templates: ./template0_0.sac
% output_files: noccresults

warning('This script was written before the creation of the cfgfile class.')

%%

% convert ChannelTag to appropriate string format
% tag.string -> 'RC.KBUR.--.EHZ'
% cfg file needs -> 'UW HSR EHZ ..'

for n = 1:numel(tag)
    tag_str{n} = [tag(n).network ' ' ...
        tag(n).station ' ' ...
        tag(n).channel ' ' ...
        tag(n).location];
end

% fill empty entries with defaults
for n = 1:numel(etime)
   
    if isempty(line_name), line_name{n} = 'name'; end
    if isempty(etime), error('You must supply event times.'); end
    if isempty(lat), lat(n) = 0; end
    if isempty(lon), lon(n) = 0; end
    if isempty(depth), depth(n) = 0; end
    if isempty(mag), mag(n) = 0; end
    if isempty(mag_type), mag_type{n} = 'm'; end
    if isempty(mag_type), pick{n} = 'P'; end
    if isempty(picktime), picktime(n) = etime; end
    
end

% change etime and picktime into proper syntax
etime = datestr(etime, 'yyyy/mm/dd HH:MM:SS');
picktime = datestr(picktime, 'yyyy/mm/dd HH:MM:SS');

% put core info into a table; write table to a temporary file
T = table(line_name, etime, lat, lon, depth, mag, magtype, ...
    tag_str, pick, picktime, ...
    [pathstr '/tmp_cfgprep.txt'], ...
    'WriteVariableNames', false, 'Delimiter', ' ');
writetable(T)

%% Change temp txt file to finished .cfg file

% A     : cell array of individual lines for the cfg file
% i     : tracks line number of final cfg file
% NOTES -
%  - all lines w event info must start with the string 'name '; this block
%  of code adds that string
%  - the end of the first line must have 'svd' or 'indep' at the end. Which
%  string to use is determined by the user.

fid = fopen([pathstr '/tmp_cfgprep.txt'], 'r'); % open temporary file
i = 1;
tline = fgetl(fid); % get first line of tmp file
A{i} = [tline ' ' svd_indep]; % store and edit first line of tmp file
while ischar(tline) % store all subsquent lines of tmp file
    i = i+1;
    tline = fgetl(fid);
    A{i} = tline;
end

% Add Optional Lines
% All optional lines after the event info, such as the filter definition,
% are passed to this function as input arguments. Here, we add on as many
% options as the user specifies.
for n = 1:numel(varargin)
   i = i+1; A{i} = varargin{n}; 
end


% Write cell A into txt
fid = fopen(outfile, 'w');
for i = 1:numel(A)
        fprintf(fid,'%s\n', A{i});
end

% delete the temporary file
delete([pathstr '/tmp_cfgprep.txt'])

end

