function [outputcfg, wtemplates, summaries ] = preprocess( obj, preproccfg )
%PREPROCESS Runs the NEIC Subspace Preprocessor
%
% CURRENT USAGE
% Run the Preprocessor from a Configuration object
% >> [subspacecfg, templates, ~] = preprocess(obj, preprocesscfg)
%
% ADDITIONAL FUTURE USAGE
% Run the Preprocessor from a .cfg file
% >> [subspacecfg, templates, ~] = preprocess(SD, 'Users/myfolder/preprocess.cfg')
%
% SEE ALSO SubspaceDetector Configuration

% make project folder, if necessary
if ~exist(fullfile(preproccfg.project_folder), 'dir')
    mkdir(fullfile(preproccfg.project_folder));
end

% make analysis folder, if necessart
if ~exist(fullfile(preproccfg.project_folder, preproccfg.name), 'dir')
    mkdir(fullfile(preproccfg.project_folder, preproccfg.name));
end

% write out cfg file
ifilename = fullfile(get_folderpath(preproccfg), 'preprocess.cfg');
writecfg(preproccfg, ifilename)

% run the NEIC Preprocessor.jar file
system(['java -jar ' obj.preprocjar ' ' ifilename])

% move output cfg files to correct location
SubspaceDetector.move_new_cfg_files(preproccfg);

% load cfg file as Configuration object
warning('This script is only set up to upload cfg files with the following string: ''RCKBUR''.')
ofilename = dir(fullfile(get_folderpath(preproccfg), 'RCKBUR*cfg'));
outputcfg = rdcfg(fullfile(get_folderpath(preproccfg), ofilename(1).name));
outputcfg.project_folder = preproccfg.project_folder; % preserve folder name
outputcfg.name = preproccfg.name; % preserve config name
outputcfg.svd_indep = preproccfg.svd_indep;
outputcfg.T = preproccfg.T; % preserve event info

% load waveform templates
warning('Current implementation uses PLOTTEMPLATES to grab waveform objects. This function produces a plot. PLOTTEMPLATES, and therefore the automatic plot as well, may be deprecated in the future.')
wtemplates = plotTemplates(get_folderpath(preproccfg));

% load summary .dat files produced by preprocessor - not yet
% implemented
summaries = [];

end

