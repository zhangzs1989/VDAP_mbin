function be = empiricalbeta(t, b, background, thresh)
% EMPIRICALBETA Calculate empirical beta
% Selects empirical beta with a % threshold against sorted beta values. No
% random sampling.
%
% USAGE
% >> be = empiricalbeta(t, b, background, thresh)
%
% INPUT
% * t           : 1-by-n datetime   : timeseries vector corresponding to b
% * b           : 1-by-n double     : vector of beta values corresponding to t
% * background  : m-by-2 datetime   : matrix of start/stop times that
%                                       define when empirical beta should
%                                       be calculated
% * thresh      : double            : confidence level (percentage)
%                                       e.g., '0.95' means empirical beta
%                                       is the value at which beta exceeds
%                                       the threshold only 5% of the time
%
% OUTPUT
% * be          : double            : empirical beta calculation
%

[~, idx, ~] = withininterval(datenum(t), datenum(background), 4);
b(~idx) = [];

b = sort(b);
be = b(ceil(numel(b)*thresh));

