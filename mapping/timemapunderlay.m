function ax = timemapunderlay( ax, lat, lon, varargin )
%TIMEMAPUNDERLAY Plots an underlap map beneath a timemap

x = ones(size(lat));
y = lon;
z = lat;

ax1 = axes();
ax1.Position = ax(1).Position;
plot3(x, y, z, varargin{:}); hold on;
linkprop([ax ax1],{'Position', 'YLim', 'ZLim', 'View'});
uistack(ax1, 'bottom');
ax1.XTick = [];
ax1.YTick = [];
ax1.ZTick = [];

end

