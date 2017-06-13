function ax = timemap( t, lat, lon, varargin )
%TIMEMAP Plots a map where element visibility can be tied to a timeseries
%plot.
%Use LINKAXES to link the x-axis of the time series plot to the time
%dimension of the map. See usage example below.
%To overlay static plot elements that are always visible regardless of zoom
%level, use TIMEMAPOVERLAY*.
% * in development
%
% >> ax(1) = subplot(1,5,1:3);
% >> plot(t, mag, 'ok')
% >> ax(2) = subplot(1,5,4:5);
% >> timemap(t, lat, lon, 'ok')
% >> linkaxes(ax, 'x')
%

% seismicTS_v1

x = t;
y = lon;
z = lat;

plot3(x, y, z, varargin{:}), hold on
ax = gca;
ax.View = [90 0];

% beautifying
% ax.ZTick = [ax.ZTick(1) ax.ZTick(end)];
% ax.YTick = [ax.YTick(1) ax.YTick(end)];
% ax.Box = 'on';

%%% This becomes necessary if there is an overlay map
% Therefore, I think this should be added to the timemapoverlay function
% yl = ax.YLim; ax.YLimMode = 'manual'; ax.YLim = yl;
% zl = ax.ZLim; ax.ZLimMode = 'manual'; ax.ZLim = zl;

end

