function [w, dn] = loadswarmcb( folderpath )
%% LOADSWARMCB Loads waveforms saved from the Swarm Clipboard
%   Only works for SAC files
%
% See also waveboard

files = ls(fullfile(folderpath,'*','*.sac'));
files = strsplit(files, '.sac');

for n = 1:numel(files)

    files{n} = strtrim(files{n});
    
    if ~isempty(files{n})
        
        % get start time from filepath
        [path, ~, ~] = fileparts(files{n});
        [~, datestr, ~] = fileparts(path);
        dn(n) = datenum(datestr, 'yyyymmddHHMMSS');
        
        ds = datasource('sac', [files{n}, '.sac']);
        tag = ChannelTag('*.*.*.*');
        w(n) = waveform(ds, tag, now-2000, now);
        
    end
    
end

end