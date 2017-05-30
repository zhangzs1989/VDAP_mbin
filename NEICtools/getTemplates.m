function w = getTemplates( detection_folder, varargin)
%PLOTTEMPLATES Special routine for getting templates produced by NEIC
%Subspace Preprocessor. Returns waveform objects.
%
% USAGE
% Simply provide a directory that holds sac files of templates for a
% standard plotting of the data
% >> w = getTemplates('/Volumes/ALBERTA/Raung_test1/Analysis0/')
%
% This script is designed specifically to retrieve the .sac files that are
% produced by the NEIC Subspace Preprocessor.

%%

% initialize waveform object
w = waveform();

% retrieve all .sac files in the Detection/Analysis folder
files = dir(fullfile(detection_folder,'*sac'));

% loop through all .sac files, save the waveform object, and print to a
% subplot
for n = 1:numel(files)

    ds = datasource('sac', fullfile(detection_folder, files(n).name) ); % full path is folder name plus filename
    tag = ChannelTag('...'); % empty channel tag
    w(n) = waveform(ds, tag, now-2000*365, now); % must provide time window, so I just use 2000 years ago until now
    
end

end