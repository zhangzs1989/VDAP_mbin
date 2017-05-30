function [outputcfg, wtemplates, summaries ] = preprocess( obj, preproccfg )
%PREPROCESS Runs the NEIC Subspace Preprocessor
%
% CURRENT USAGE
% Run the Preprocessor from a Configuration object
% >> [subspacecfg, templates, ~] = preprocess(SubspaceDetector(...), preprocesscfg)
%
% ADDITIONAL FUTURE USAGE
% Run the Preprocessor from a .cfg file
% >> [subspacecfg, templates, ~] = preprocess(SubspaceDetector(...), 'Users/myfolder/preprocess.cfg')
%
% SEE ALSO SubspaceDetector Configuration

%%

% if isa(preproccfg, 'Configuration')
%     
%     cfgobj = 1;
%     % continue with this code
%     
% elseif ~isempty(dir(preproccfg))
%     
%     cfgobj = 0;
%     preprocess_fromfile(obj, preproccfg);
%     
% else
%     
%     error('The second input argument must be either a Configuration object or a .cfg file. Double-check your inputs.')
% 
% end

%% Initial display
disp('  Running Preprocessor...')
% disp('    *system command output will not be printed to this screen')
disp(['    Processing ' num2str(numel(preproccfg.T.dn1)) ' seed events into templates.'])

%% Manage directories and files

% make project folder, if necessary
if ~exist(fullfile(preproccfg.project_folder), 'dir')
    mkdir(fullfile(preproccfg.project_folder));
end

% make analysis folder, if necessary
if ~exist(fullfile(preproccfg.project_folder, preproccfg.name), 'dir')
    mkdir(fullfile(preproccfg.project_folder, preproccfg.name));
end

% write out cfg file
ifilename = fullfile(get_folderpath(preproccfg), 'preprocess.cfg');
writecfg(preproccfg, ifilename)

%% run
% run the NEIC Preprocessor.jar file
% [~, ~] = system(['java -jar ' obj.preprocjar ' ' ifilename]) % defining [~, ~] as output arguments supresses the output to the command window
[status, cmdout] = system(['java -jar ' obj.preprocjar ' ' ifilename]) % not defining output arguments lets the output display to the command window

%% Load output

% move output cfg files to correct location
SubspaceDetector.move_new_cfg_files(preproccfg);

% load cfg file as Configuration object
warning('This script is only set up to upload cfg files with a hardcoded network code.')
ofilename = dir(fullfile(get_folderpath(preproccfg), 'AV*cfg'));
outputcfg = rdcfg(fullfile(get_folderpath(preproccfg), ofilename(1).name));
% outputcfg.project_folder = preproccfg.project_folder; % preserve folder name
outputcfg.name = preproccfg.name; % preserve config name
outputcfg.svd_indep = preproccfg.svd_indep; % preserve svd_indep setting
outputcfg.T = preproccfg.T; % preserve event info


% load waveform templates
wtemplates = getTemplates(get_folderpath(preproccfg));

% load summary .dat files produced by preprocessor
% - not yet implemented
summaries = [];

%% Final display
disp( '    Subspace Pre-Processor complete.' )
disp(['    - Seed events processed : ' num2str(numel(preproccfg.T.dn1)) ])
disp(['    - Templates created     : ' num2str(numel(wtemplates)) ])

end
