function RESULTS = ps2ts( t, d, start_stop, t_step, t_width )
%PS2TS Converts a point series to a time series
% * accepts negative numbers for t_step
%
% INPUT
% * t           : 1-by-n datetime   : vector of point series times
%                                       * must be in ascending order
% * d           : 1-by-n double     : vector of data values
% * start_stop  : t-by-2 datetime   : start/stop pairs during which to conduct analysis
%                                       * must NOT contain any NaN or NaT values
% * t_step      : double            : length of days between each bin (days)
% * t_width     : double            : length of bin (days)
%
% OUTPUT
% * RESULTS
%   .tc         : 1-by-m datetime   : start times of check windows
%   .binCounts     : 1-by-m double     : # of eqs in each window 
%   .binData       : 1-by-m double     : cumulative Moment in each window
%   .bv         : 1-by-m double     : beta value for each window
%   .N          : double            : total # of eqs in entire window
%   .T          : double            : total time (days) in entire window
%
% USAGE
% where eqt is a vector of earthquake event times
%       eqMo is a vector of corresponding moments for those earthquakes
%       background_time is an n-by-2 vector of times over which to make the
%       time series
%       return 30 day sums recalculated every day moving forward in time
% >> TS = ps2ts(eqt, eqMo, background_time, 1, 30);
%
% NOTE: N may vary slightly from numel(binCounts) and T may vary slightly from
% numel(tc) * t_width because of the way window spacing happens
%

RESULTS = [];
t = reshape(t, 1, numel(t));
d = reshape(d, 1, numel(d)); 

start_stop(isnat(start_stop(:,1)), 1) = start_stop(isnat(start_stop(:,1)), 2); % ensure that there are no NaN values in start_stop
start_stop = datenum(start_stop);
a = start_stop;

if t_step < 0, b = fliplr(flipud(a)); adj = 0; else, b = a; adj = t_width; end

tc1 = [];
for n = 1:size(b, 1), tc1 = [tc1 b(n,1):t_step:b(n,2)-adj]; end

tc(:,1) = sort(tc1');
tc(:,2) = tc(:,1) + t_width;

[~, ~, countmat] = withininterval(t, tc, 3);
datamat = countmat .* d;

if t_step < 0 % retrospective bins
    t = tc(:,1)';
    binCounts = sum(countmat');
    bindata = sum(datamat');
    nanidx = ismember(t, b(:,1));
    binCounts(nanidx) = NaN;
    bindata(nanidx) = NaN;
else % forward moving bins
    t = unique([tc(:,2) tc(:,2)-t_step]);
    binCounts = nan(size(t));
    bindata = nan(size(t));
    binCounts(ismember(t, [tc(:,2)-t_step])) = sum(countmat');
    bindata(ismember(t, [tc(:,2)-t_step])) = sum(datamat');
end

% Save results to structure
idx = ~isnan(t);
RESULTS.tc = datetime2(t(idx));
RESULTS.binData = bindata(idx);
RESULTS.binCounts = binCounts(idx);

end

