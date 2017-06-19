function [w2, n] = mcvco2nan(w)
% MCVCO2NAN Uses decode_mcvco to replace a calibration pulse +/- 5 seconds
% with NaN values
% 
% * Finds and replaces multiple cal pulses (this function has not been
% tested on a waveform w multiple cal pulses since this feature was 
% implemented)
%
% USAGE
% >> w = mcvco2nan(w); % replace cal pulses with NaN's
% >> w = fillgaps(w, 0); % replace those NaN's w 0's so that other
% operations can be performed
%

% developer notes
% * care has been taken to find multiple cal pulses
% * care has been taken to make sure infinite loops are not entered if
% there are no cal pulses found or if there are cal pulses found

sst = 1; % initialize value
w2 = w;
n = 0; % number of cal pulses found

while ~isnan(sst)
    
    disp('looking for cal pulse')
    sst = decode_mcvco(w2, 'sst');
    
    if ~isnan(sst)
        
        n = n + 1;
        sst(:,1) = sst(:,1) - 5/86400;
        sst(:,2) = sst(:,2) + 5/86400;
        isst = interinterval(sst, get(w,'start'), get(w,'start')+get(w,'duration'));
        w2 = combine(extract(w2, 'time', isst(:,1), isst(:,2)));
        
    end
    
% close all, plot(w, 'r'), hold on, plot(w2, 'k')    
end


end