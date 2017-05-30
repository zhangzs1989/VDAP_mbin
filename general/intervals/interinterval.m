function c = interinterval( interval, start, stop )
%INTERINTERVAL Given n intervals defined by start/stop pairs
%and a start value and a stop value, returns the start/stop times of the
%interevent time periods.
%
% Example 1:
%
% >> interval = [3 5; 9 12]
% ans =
%    3   5
%    9  12
%
% >> interinerval( interval, 1, 15)
% ans = 
%    1   3
%    5   9
%   12  15
%

%%

a = interval;
a(a<start) = start;
a(a>stop) = stop;
b(:,1) = [a(:,1); stop];
b(:,2) = [start; a(:,2)];
c = fliplr(b);
c(c(:,2) <= c(:,1), :) = [];

end

