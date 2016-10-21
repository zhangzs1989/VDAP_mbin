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

    % write out the cfg file
    filename = fullfile(get_folderpath(subspacecfg), 'subspace.cfg');
    writecfg(subspacecfg, filename);

    % run the NEIC SubspaceDetector.jar file
    system(['java -jar ' obj.detectjar ' ' filename])
    
    % load .dat files that have detections
    files = fullfile(get_folderpath(subspacecfg), '*summary.dat');
    T = rdSummaryDat(files);

end