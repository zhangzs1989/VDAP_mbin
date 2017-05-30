function h = plot( obj )
%PLOT Plots alert level changes using the PATCH function
%   Requieres the PATCH2 function form VDAP_mbin

% known issues
% t1 and t2 should be defined differently

plot_start = datenum(obj.plot_start);
plot_end = datenum(obj.plot_end);
date = datenum(obj.date);
% plot_start = obj.plot_start;
% plot_end = obj.plot_end;
% date = obj.date;


t1 = [plot_start; date];
t2 = [date; plot_end];
dates = [t1 t2];
heights = [zeros(size(t1)) ones(size(t1))];
clrs = obj.patch_colors;
clrs = [clrs(1,:,:); clrs];

patch2(dates, heights, clrs);
% fill2(dates, heights, clrs);

ax = gca;
ax.YTick = [];
ax.Box = 'on';
datetick(gca)
zoom('xon')

% makedatetimexaxis;

end

