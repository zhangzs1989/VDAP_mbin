function p2 = mergeperiods( p )
%MERGEPERIODS
% This function has been renamed to MERGEINTERVALS. Please use that 
% function instead.
%
% E.g.,
% >> p
% p =
%      1     5
%      3     7
%      5     9
%     11    16
%     14    18
%     21    23
%     24    25
%      2     4
%
% >> mergeperiods(p)
% ans =
%      1     9
%     11    18
%     21    23
%     24    25
%
% SEE ALSO MERGEINTERVALS

%%

% SEE PROGRAMMER'S NOTE BELOW FOR DETAILS

warning('This function has been renamed to MERGEINTERVALS. Please use that function instead.')


% sort the start and stop times each in ascending order
p(:,1) = sort(p(:,1));
p(:,2) = sort(p(:,2));

% get the minimum value in the matrix and the maximum value
minstart = min(min(p));
maxstop = max(max(p));

% identify start times from the original matrix that should still be start
% times (indicated when isstart>0)
% identify stop times from the original matrix that should still be stop
% times (indicated when instop>0)
isstart = p(:,1) - [minstart-1; p(1:end-1, 2)];
isstop = [p(2:end,1); maxstop+1] - p(:,2);

p2(:,1) = p(isstart>0, 1);
p2(:,2) = p(isstop>0, 2);

end

% PROGRAMMGER'S NOTE
%{
If the given matrix is:

    1   5
    2   4
    3   7
    5   9
    11  16

To get the start time, perform the following operation:
    (1) column1 - [x; column2]
        where x is the minimum value of the matrix minus 1

To get the stop times, perform the following operation:
    (2) [column1(2:end); y] - column1
        where y is the maximum value of the matrix plus 1

For the above example values, the operations are
    (1) 1 - 0 =    1 <-- 1 is a starting value
        2 - 5 =   -3
        3 - 7 =   -4
        5 - 9 =   -4
        11- 9 =    2 <-- 11 is a starting value

    (2) 2 - 5 =   -3
        3 - 4 =   -1
        5 - 7 =   -2
        11- 9 =    2 <-- 9 is a stopping value
        17-16 =    1 <-- 16 is a stopping value

%}

