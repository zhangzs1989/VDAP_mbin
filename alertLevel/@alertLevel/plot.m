function h = plot( obj )
%PLOT Plots alert level changes using the PATCH function
%   Requieres the PATCH2 function form VDAP_mbin

% known issues
% t1 and t2 should be defined differently

t1 = [obj.plot_start; obj.date];
t2 = [obj.date; obj.plot_end];
dates = [t1 t2];
heights = [zeros(size(t1)) ones(size(t1))];
clrs = obj.patch_colors;
clrs = [clrs(1,:,:); clrs];

patch2(dates, heights, clrs);

ax = gca;
ax.YTick = [];
ax.Box = 'on';
datetick(gca)
zoom('xon')

makedatetimexaxis;

end

