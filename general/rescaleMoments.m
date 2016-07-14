function A = rescaleMoments( vec, R, varargin)
% RESCALE Rescales vector quantities to a given range.
% This function is useful when plotting event magnitudes or moments.
%
% INPUT:
% vec - vector of magnitudes or moments (or any other data value)
% R - range of values that you want the vector to be scaled to
% (optional) - [n-by-2] additional data values to be used to force the scaling
%
% OUTPUT
% A - plot sizes for the vector input
%
% USGAGE:
% Rescale a vector of magnitudes to a range of plot sizes
% >> markersize = rescaleMoments([-1.1 0.8 5.2 6.3 6.7], [5 100])
%
% Rescale a vector of magnitudes to a range of plot sizes, but base the
% resizing on a minimum and maximum data value. I.e., if all of your
% magnitudes are M5s and M6s and you want all of them to look large
% you might want to scale everything from a M2 to M7 range.
% >> markersize = rescaleMoments([5.2 6.3 6.7], [5 100], [2 7])

% modified from a post on StackOverflow
% UPDATES
%{
2015 Dec 10 - If there is only one magnitude, the result is nan values. Fix
this.

%}

%% Parse varargin

A = vec; % input vector
dR = diff( R ); % range of requested output

% If there is a hard-inputs for min and max data values, add these to the
% vector (append at beginning)
if nargin==3, A = [varargin{1} A]; end


%%

A =  A - min( A(:)); % set range of A between [0, x]
if diff(A)==0, A(:) = 0.5; else A =  A ./ max( A(:)) ; end % set range of A between [0, 1] (See Note below)
A =  A .* dR ; % set range of A between [0, dR]
A =  A + R(1); % shift range of A to R

%%

% exclude hard-inputs for min and max data values
% remove first two values because hard-inputs were appended at beginning
if nargin==3, A = A(3:end); end


%% NOTES
%{
>> if diff(A)==0, A(:) = 0.5; else A =  A ./ max( A(:)) ; end % set range of A between [0, 1] (See Note below)
The purpose of the above line is to avoid the case where all of the values
in A are equal. If this is true, set the rescaled value to 0.5 for the
entire vector. If this is not done, each value would be 0, which would
later result in a NaN value.
%}