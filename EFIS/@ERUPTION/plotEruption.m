function [ax, p] = plotEruption( obj )
%PLOTERUPTOIN Uses the Matlab PATCH function to plot eruption windows
% see also PATCH
%%

% Plot a transparent box from the start time to the stop time. Plot the box
% on its own axis.
ax = axes();
ax.YTick = [];
ax.NextPlot = 'add';
% p = patch([obj.start obj.start obj.stop obj.stop],[0 1 1 0],[1 0.5 0.5],'FaceAlpha',0.5);
% p = patch([obj.start obj.start obj.stop obj.stop],[0 1 1 0],[1 0 1],'FaceAlpha',0.5);
for n = 1:numel(obj)

    p(n) = patch([obj(n).start obj(n).start obj(n).stop obj(n).stop],[0 1 1 0],...
        [0.9 0.4 0.4], 'EdgeColor', [0.9 0.4 0.4], 'LineWidth', 0.75);
    
    if obj(n).stop-obj(n).start <= 1; p(n).LineWidth = 2; p(n).EdgeColor = p(n).FaceColor; end

end

end

