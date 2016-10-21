function dat2cfg( infile, outfile, svd_indep, varargin )
%DAT2CFG Reads a .dat file of detection results and turns it into a .cfg 
%file for the preprocessor
%   This is used if you want to turn your detections into templates
%
% dat2cfg('./HSR_2016_267.dat', 'preprocess2.cfg', 'svd', ...
%   'bandpass: 2 8 3', 'output_path: ./', ...
%   'input_cwb: localhost 2061', 'template_parameters: 600 5 5 -.1')
%


%{
Reading in a .dat file will evetually make use of ECATALOG routines, so
check if ECATALOG is available or else do so without the ECATALOG.

date string still isn't written properly.
datestr should look like this -> 2004/09/23 20:06:03.224

%}

%%

% store path of output file for book-keeping
[pathstr, ~, ~] = fileparts(outfile);
if ~exist(pathstr, 'dir'), mkdir(pathstr), end

%% read .dat file
% import dat file using RDSUBSPACESUMMARY - note, this may be deprecated in
%  the future, so this block of code might need to change in the future


T = rdSummaryDat( infile ); % import results as table
% add a datestring line to the table
T.ds1 = datestr(T.dn1, 'yyyy/mm/dd HH:MM:SS');
T.ds2 = datestr(T.dn2, 'yyyy/mm/dd HH:MM:SS'); 

% write table of event info to a temporary txt file
% include only lines of table that are used in cfg file
writetable(T(:, {'ds1' 'lat' 'lon' 'est_mag' 'est_mag' 'mag_type' ...
    'NT' 'STA' 'CHA' 'LO' 'phase' 'ds2'}), ...
    [pathstr '/tmp_cfgprep.txt'], ...
    'WriteVariableNames', false, 'Delimiter', ' ');

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
A{i} = ['name ' tline ' ' svd_indep]; % store and edit first line of tmp file
while ischar(tline) % store all subsquent lines of tmp file
    i = i+1;
    tline = fgetl(fid);
    A{i} = tline;
end

% edit 2nd through remaining lines of tmp file
for n = 2:numel(A)-1
    A{n} = ['name ' A{n}];
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