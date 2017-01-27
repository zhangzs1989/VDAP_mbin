function obj = merge( obj )
%MERGE Merges info statements that do not actually change the color code

d = [1; diff(obj.level)];
obj.level(d==0) = [];
obj.date(d==0) = [];

% *
% when diff==0, the alert level did not change;
% append 1 at the beginning so the vector is the same length as the input
% data, and so that diff==0 corresponds to the same index as the repeated
% alert level

end

