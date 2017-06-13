function ax1 = timemapoverlay( ax, lat, lon, varargin )
%TIMEMAPOVERLAY Plots an overlap map over a timemap
%Use LINKAXES to link the x-axis of the time series plot to the time
%dimension of the map. See usage example below.
%To overlay static plot elements that are always visible regardless of zoom
%level, use TIMEMAPOVERLAY*.
% * in development
%
% >> axm = timemap(...)
% >> axm2 = timemapoverlay(axm, ...)

x = ones(size(lat));
y = lon;
z = lat;

ax1 = axes();
ax1.Position = ax.Position;
plot3(x, y, z, varargin{:}); hold on;
linkprop([ax ax1],{'Position', 'YLim', 'ZLim', 'View'});
ax1.Color = 'none';
ax1.XTick = [];
ax1.YTick = [];
ax1.ZTick = [];

end

