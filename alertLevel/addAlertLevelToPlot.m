function [ ax, new_ax ] = addAlertLevelToPlot( ax, color_code_struct, varargin )
%ADDWARNINGLEVELTOPLOT Adds a bar with the warning level color codes to the
%top of a pre-existing plot.
%
% INPUT:
% AX - axis handle for the axis that you want to pair with the color codes
% 
% COLOR_CODE_STRUCT - structure containing color code information
% .DATE_DN - [double] vector of datenums for the start of each color code change
% .LEVEL - [double] vector of alert levels; must be numeric
% 
% OPTIONAL INPUT:
% 'type' - the type of alert level system to use
%  : e.g., ('4 step generic') | 'AVO' | 'AVO Aviation' | 'CVO' | 'PVMBG' | "CVGHM' | 'Indonesia'
% 
% OPTIONAL INPUT: (not yet implemented)
% 'location' - location of where color code plot will appear relative to paired plot
%  :e.g., ('top') | 'bottom'
% 'height' - the height of the color code bar as a percentage of the original
% plot's original height - e.g., 1/8 or 0.125 (default: 0.1)
% 'merge info statements' - allows for info statements that do not have a
% corresponding change in the alert level to be merged with the latest
% alert level change
%  :e.g., (true) | false
%
% 
% OUTPUT:
% AX - updated handle to original plot axis
% NEW_AX - handle to alert level plot axis
%
% USAGE:
% >> [rsam_ax, alert_ax] = addAlertLevelToPlot( rsam_ax, RaungAlertLevel, 'type', 'CVGHM', 'merge info statements', true)
%

% --- This could go into the help somewhere for the 'merge info statements'
% feature:
% ---
% Sometimes institutions issue information statements that simply restate
% the previous alert level. These information statements may exist in the
% time series data, but you might the plot to make the color code value
% seem seemless. This bit of code combines consecutive information
% statements with the same alert level into one setting

% Things that coule be improved:
% - how long should the most recent alert level be plotted for?

% Author: Jay Wellik, USGS-VDAP, jwellik <at> usgs.gov
% Created: Dec 17, 2015

%% Define Defaults

('Warning: This script has not been modified to work with the object oriented design of alertLevelChron and alertLevelSchema.')

new_plot_height = 0.1;
colorcode = color_code_struct;

plot_location = 'top'; % 'location' currently unused
color_code_type = '4 step generic'; % 'type'

%% Parse varargin

var_props = parsePairedArgs( varargin ); % parse pairs of input arguments

for n = 1:length(var_props.name)
    
    switch lower(lower(var_props.name{n}))
        
        case 'type'
            
            color_code_type = var_props.val{n};
            
        case 'location'
            
            plot_location = var_props.val{n};
            
        case 'merge info statements'
            
            % Merges info statements that do not actually change the color
            % code.
            
            if var_props.val{n} % if the merge feature is set to true
                
                levelchange = diff(colorcode.level); % returns the amount that the level changed for each value
                newlevel_idx = [1; find(levelchange ~= 0) + 1]; % returns index of values that correspond to a change in the level; index of the first value must be appended to the beginning of this series
                original_data = colorcode; % save the original data
                
                colorcode = structfun(@(x) ( x(newlevel_idx) ), colorcode, 'UniformOutput', false); % apply indexing to all fields in the structure
                colorcode.original_data = original_data; % add original data back to the structure incase you want to retrieve it later
                
            end
            
        otherwise
            
            error([var_props.name{n} ' is not a valid input argument.'])
    
    end
    
end


%% Definitions for color code
% Define the color pattern for alert levels used by different institutions.

switch lower(color_code_type)
    
    case lower({'4 step generic', 'Indonesia', 'PVMBG', 'CVGHM', 'Alaska Aviation', 'AVO'})
   
        color(1,:) = [0 0.7 0.3]; % green
        color(2,:) = [1 1 0.4]; % yellow
        color(3,:) = [1 0.5 0]; % orange
        color(4,:) = [1 0.25 0.25]; % red
        
        
    case lower('5 step generic')
        
            % change range from [0 4] to [1 5] so that it works with
            % enumerated plotting routine
        colorcode.level = colorcode.level + 1;
        
        color(1,:) = [0 0 0]; % white
        color(2,:) = [0 0.7 0.3]; % green
        color(3,:) = [1 1 0.4]; % yellow
        color(4,:) = [1 0.5 0]; % orange
        color(5,:) = [1 0.25 0.25]; % red
        
    case lower('Columbia')
        
        % not yet implemented
        
    case lower('Cascades')
        
        % not yet implemented
        
    otherwise
        
        error('The color code you selected is not supported.')
        
end

%% Define position of original and new axes

f = ax.Parent; % get the handle for the correct figure

    % define new y-values and heights for the original axis
original.h1 = ax.Position(4); % initial height of first plot
original.y1 = ax.Position(2); % initial y value of first plot axis
original.h2 = original.h1 * (1 - new_plot_height); % second height of original plot
original.top1 = original.y1 + original.h1; % the initial top value for the original plot
original.top2 = original.y1 + original.h2; % second top value for original plot

    % define y-values and height for new axis
new.y = original.y1 + original.h2;
new.h = original.top1 - original.top2;
ax.Position(4) = original.h2;

%% create the new axis

    % create the new axis
figure(f); % ensure that the correct figure is present
new_ax = axes('Position',[ax.Position(1) new.y, ax.Position(3) new.h]); % set the position
new_ax.Tag = 'Color Code';

%% plotting routine

    % plot alert levels for background
axes(new_ax)
if exist('colorcode','var')
    
    for n = 1:length(colorcode.date_dn)-1
        
        rectangle('Position',[colorcode.date_dn(n) 0,...
            colorcode.date_dn(n+1)-colorcode.date_dn(n) 1],...
            'FaceColor',color(colorcode.level(n),:)); hold on; % choose color based on info given by the level
        
    end
    rectangle('Position',[colorcode.date_dn(end) 0 100000 1],'FaceColor',color(colorcode.level(end),:)); hold on;
    
end



%%

    % link axes and define zoom properties
new_ax.YTick = [];
new_ax.XTick  = [];
linkaxes([ax new_ax],'x')
zoom(ax.Parent,'xon')

end