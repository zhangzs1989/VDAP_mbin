function hndl = wingplotm(varargin)
%WINGPLOTM Project 3-D lines and points on map axes and cross section
%profiles.
%
% NOTE: The rest of the documentation has not been changed
%
%  PLOTM(lat,lon) projects line objects onto the current
%  map axes.  The input latitude and longitude data must be in
%  the same units as specified in the current map axes.
%  PLOTM will clear the current map if the hold state is off.
%
%  PLOTM(lat,lon,'LineSpec') uses any valid LineSpec string to
%  display the line object.
%
%  PLOTM(lat,lon,'PropertyName',PropertyValue,...) uses
%  the line object properties specified to display the line
%  objects.  Except for xdata, ydata and zdata, all line properties,
%  and styles available through PLOT are supported by PLOTM.
%
% NOTE: One significant difference between PLOTM and WINGPLOTM is that a
% single input matrix is not an option in WINGPLOTM
%  x PLOTM(mat,...) uses a single input matrix, mat = [lat lon],
%  x where the first half of the matrix columns represents the
%  x latitude data and the second half of the columns represent
%  x longitude data.
%
%  h = PLOTM(...) returns the handles to the line objects displayed.
%
%  See also PLOTM, PLOT3M, PLOT, LINEM, LINE.

% PLOTM
% Copyright 1996-2009 The MathWorks, Inc.
% Written by:  E. Byrns, E. Brown

% WINPLOTM
% Written by: Jay Wellik (2016 July 14)
% Last modified: 

% Things to work on
%{
It needs to recognize if a wingplot already exists so that it doesn't
create new cross section axes on top of the old ones. Cross section plots
should be taking advantage of hold on. The map plot is working fine in
regards to this, so maybe looking at how that works is a clue to how to
make the cross sectional plots work.
%}

%%

% use this template wingplot design to set the position values for all
% of the axes

stubf = figure;
ax1 = subplot(3,3,[1 2 4 5]);
ax2 = subplot(3,3,[3 6]);
ax3 = subplot(3,3,[7 8]);
mpos = ax1.Position;
hpos = ax3.Position;
vpos = ax2.Position;
close

%% ORIGINAL PLOTM

% if nargin == 0
% 	linem;
%     return
% else
% 	lat = varargin{1};
%     if nargin >= 3;
%         lon = varargin{2};
%         depth = varargin{3};
%     else
%         lon = [];
%         depth = [];
%     end
% 
%     if ischar(lon) || nargin == 1
%         if size(lat,2) < 2
% 	        error(['map:' mfilename ':mapdispError'], ...
%                 'Input matrix must have at least two columns')
% 	    elseif rem(size(lat,2),2)
% 	        error(['map:' mfilename ':mapdispError'], ...
%                 'Input matrix must have an even number of columns')
% 	    else
% 		    indx = (1 + size(lat,2)/2) : size(lat,2);
% 		    lon = lat(:,indx);
%             lat(:,indx) = [];
%         end
%         varargin(1) = [];
%     else
%         varargin(1:3) = [];
%     end
% end

%% New to WINGPLOTM

if nargin <2, error('at least two inputs are required'); end
lat = varargin{1};
lon = varargin{2};
depth = nan(size(lat));

if nargin == 3

        
        if isnumeric(varargin{3})
            depth = varargin{3};
            varargin(1:3) = [];
        else
            varargin(1:2) = [];
        end
        
elseif nargin >= 4
        
        if isnumeric(varargin{3})
            depth = varargin{3};
            varargin(1:3) = [];
        else
            varargin(1:2) = [];
        end
        
end


%%

% Create axes for cross section profiles
f = gcf;
f.Children % stub


%  Display the map
% nextmap(varargin)
if numel(f.Children) > 1
    axes(f.Children(end))
    axm = gcm;
else
    axm = gcm;
    axm.Tag = 'Map';
end



%% plot the data on the map
if ~isempty(varargin)
    hndl0 = linem(lat,lon,varargin{:});
else
    hndl0 = linem(lat,lon);
end

%  Set handle return argument if necessary
if nargout == 1
    hndl = hndl0;
end


%%

if ~isnan(depth)
    axh = axes; % create horizontal axis
    axh.Tag = 'horizontal';
    axv = axes; % create vertical axis
    axv.Tag = 'vertical';
    
    % reset position for map axis
    f.Children(3).Position = mpos;
    % f.Children(3).Position(3) = f.Children(3).Position(3)/2;
    % f.Children(3).Position(4) = f.Children(3).Position(4)/2;
    
    
    % set position for cross section profiles
    % axh.Position = [0.1300 0.1100 0.650 0.25];
    % axv.Position = [0.8 0.200 0.250 0.650];
    axh.Position = hpos;
    axv.Position = vpos;
    
    
    % plot the data
    if ~isempty(varargin)
        axes(axh), plot(lon, -depth, varargin{:})
        axes(axv), plot(axv, depth, lat, varargin{:})
    else
        plot(axh, lon, -depth)
        plot(axv, depth, lat)
    end
end

display('done')

% set the limits of the cross section profiles
