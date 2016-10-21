function w = plotTemplates( detection_folder, varargin)
%PLOTTEMPLATES Special routine for plotting templates produced by NEIC
%Subspace Preprocessor. Also returns waveform objects.
%
% USAGE
% Simply provide a directory that holds sac files of templates for a
% standard plotting of the data
% >> w = plotTemplates('/Volumes/ALBERTA/Raung_test1/Analysis0/')
%
% After the directory, additional arguments can be passed to change the
% appearance of the waveforms. You can pass any set of arguments that are
% recognized by waveform/plot
% >> w = plotTemplates('/Volumes/ALBERTA/Raung_test1/Analysis0/', 'k')
%
% This script is designed specifically to retrieve the .sac files that are
% produced by the NEIC Subspace Preprocessor.

%%

% retrieve all .sac files in the Detection/Analysis folder
files = dir(fullfile(detection_folder,'*sac'));

% loop through all .sac files, save the waveform object, and print to a
% subplot
for n = 1:numel(files)

    ds = datasource('sac', fullfile(detection_folder, files(n).name) ); % full path is folder name plus filename
    tag = ChannelTag('...'); % empty channel tag
    w(n) = waveform(ds, tag, now-2000*365, now); % must provide time window, so I just use 2000 years ago until now
    subplot(numel(files),1,n)
    plot(w(n), varargin{:});
    ax = gca;
    ax.Title.String = '';
    if n==1, ax.Title.String = ['Templates Waveforms for ' detection_folder]; end
    ax.YTick = [];
    ax.YLabel.String = '';
    
end

% remove vertical spaces between subplot axes
f = gcf;
ax = f.Children;
ax = squishY(ax);

end

