function makedatetimexaxis
%MAKEDATETIMEXAXIS Changes current axis from datenum to datetime by
%copying the current axis, removing the xtick labels from the first axis,
%creating the new axis with a datetime vector, and linking the two axes
%   Detailed explanation goes here

warning('This function is only necessary for versions where datetime is not supported for FILL.')

old  = gca;
new = axes();
new.Position = old.Position;
plot(new, datetime(datestr(old.XLim)), [NaN NaN]);
old.XTick = [];
new.Box = 'Off';
new.YTick = [];
new.Position(4) = 0;
linkaxes([old new], 'x');

end

