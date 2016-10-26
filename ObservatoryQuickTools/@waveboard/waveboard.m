classdef waveboard
%WAVEBOARD Handles plotting for multiple waveform objects
% Meant to mimic Swarm's waveform Clipboard. Allows the user to toggle
% between waveform, specgram, or spectra for each trace
%
% PROPERTIES
% w         : 1-by-n waveform objects
% squishY   : ( 'on' | {'off'} ) - 'on' removes vertical spaces between
%               each plot axis
%
% USAGE
% Plot waveform objects to a waveboard using a black line and no vertical
% spaces between the plots
% >> wb = waveboard(w);
% >> wb.squishY = 'on';
% >> show(wb, 'k');
%
% SEE ALSO waveboard/show
    
    properties
        
        w; % waveform objects
        squishY = 'off'; % { on | OFF } squishY = 'on' removes all vertical spacing between the axes
              
    end
    
    methods
        
        % Constructor method for a waveboard object
        function obj = waveboard( w )
           
            obj.w = w;
            
        end
        
    end
    
end

