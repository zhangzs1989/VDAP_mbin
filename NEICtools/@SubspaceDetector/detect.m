function T = detect( obj, subspacecfg)
% DETECT Runs the NEIC Subspace Detector
%
% CURRENT USAGE
% Run the Detector from a Configuration object
% >> DETECTIONS = detect( SD, subspacecfg)
%
% ADDITIONAL FUTURE USAGE
% Run the Detector from a .cfg file
% >> DETECTIONS = detect( SD, '/Users/myfolder/subspace.cfg')
%
% SEE ALSO SubspaceDetector Configuration

disp('  Running Subspace Detector...')
% disp('    system command output will not be printed to this screen')

% write out the cfg file
filename = fullfile(get_folderpath(subspacecfg), 'subspace.cfg');
writecfg(subspacecfg, filename);

% run the NEIC SubspaceDetector.jar file
% [~, ~] = system(['java -jar ' obj.detectjar ' ' filename]); % supressess output to Command window
system(['java -jar ' obj.detectjar ' ' filename]);


% load .dat files that have detections
files = fullfile(get_folderpath(subspacecfg), '*summary.dat');
T = rdSummaryDat(files);

end