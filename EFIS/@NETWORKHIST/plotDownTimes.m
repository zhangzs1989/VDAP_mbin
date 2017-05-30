function [ ax, p ] = plotDownTimes( obj )
%PLOTDOWNTIMES Uses Matlab's PATCH function to plot network down times
% see also PATCH

%%

% Plot a transparent box from the start time to the stop time. Plot the box
% on its own axis.
ax = axes();
ax.YTick = [];
ax.NextPlot = 'add';
np = 0;
for n = 1:numel(obj)
    
    for i = 1:numel(status)

        if status==-1
            
            np = np+1;
            
            x1 = obj(n).date_range(i,1); x2 = obj(n).date_range(i,2);
            
            p(np) = patch([x1 x1 x2 x2],[0 1 1 0],...
                [0.8 0.8 0.8], 'EdgeColor', [0.8 0.8 0.8], 'LineWidth', 0.75);
            
            if x2-x1 <= 1; p(np).LineWidth = 2; p(np).EdgeColor = p(np).FaceColor; end
            
        end
    end
    
end




end

