function [maxes] = runningMax( data )
% RUNNINGMAX Returns a vector of data that drops everything that is not a
% new maximum value
% e.g.,
% >> data = [2 4 4 1 8 7 9 4]
% data =
%      2     4     4     1     8     7     9     4
% >> runningMax(data)
% ans =
%      2     4     4   NaN     8   NaN     9   NaN


maxes = nan(size(data)); % initialize maxes vector
cmax = data(1); % initialize current max value

for i = 1:length(maxes)
    nmax = max(data(1:i)); % get the new maximum value
    if (nmax > cmax || data(i) == cmax); % if the new max is greater than the current max or if the present data value is the same as the current max
        maxes(i) = data(i); % include the present data value in the vector of new maxes
        cmax = nmax; % update the current max
    end
end

end