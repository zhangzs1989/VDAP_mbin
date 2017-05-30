function [ss, start_idx] = series2ss( series, gap )
%SERIES2SS Converts a series of dates into start\stop pairs
%   This function only works on series of increasing values!
% 
% INPUT
% - series      : double    : vector of increasing values
% - gap         : double    : length of the gap by which to define new
%                               start/stop pair
%                             (optional - default is 1)
%
% OUTPUT
% - ss          : double    : n-by-2 matrix of start\stop dates
% - start_idx   : double    : 1-by-n vector of indices for start dates
%
% Example 1:
%
% >> t = [3 9 10 11 12 15 16 17 18 19 21]
% >> series2ss(t)
% ans = 
%      3    3
%      9   12
%     15   19
%     21   21
%
% Example 2:
%
% >> series2ss(t, 2)
% ans =
%      3     3
%      9    12
%     15    21
% 
% Here are some other examples you can try:
% t = [3 4 5 6 7 8 9 10 11 12 13 14]
% t = [3 11 12 13 14 15 16 17 18]
% t = [3 4 5 11 12 13 14 15 16 17 18]
% t = [3 4 5 6 7 8 9 21]
% t = [3 4 5 6 7 8 9 21 22 23 24]
% t = [3 4 5 6 18 19 20 21]
% t = [3]
%

%%

if nargin==1, gap = 1; end; 

idx = find(diff(series)>gap);
% idx = find(diff(series)~=gap);
stops = [idx'; series(end)];
stops = [idx series(end)];
stops = [series(idx) series(end)];
starts = [series(1) series(idx+1)];

% disp(' ')
% series
ss = [starts' stops'];
start_idx = [1 idx+1];

end

