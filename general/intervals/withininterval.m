function [data, idx_vec, idx_mat] = withininterval( data, interval, logic )
%WITHININTERVAL returns the subset of data that is within or outside of
% specified intervals
% 
% INPUT
% * data        : 1-by-n double     : row vector of data points
% * interval    : m-by-2 double     : start/stop pairs of interval limits
% * logic       : double            : option for logical expressions
%       Must be an integer from 1-4, according to:
%       (1) t1 <= x <= t2
%       (2) t1 <  x <= t2
%       (3) t1 <= x <  t2
%       (4) t1 <  x <  t2
%       * Or make the number negative to take the inverse of the logical
%       result
%
% OUTPUT
% * data        : 1-by-i double     : row vector of data points that are
%                                       either in or outside of interval
% * idx_vec     : 1-by-n logical    : index of data that are either in or
%                                       outside of any interval
% * idx_mat     : m-by-n logical    : index of of data that are either in
%                                       or outside of each interval where
%                                       m corresponds to the interval, and
%                                       n corresponds to the data point
%
%

if isa(data, 'datetime')
    data = datenum(datetime);
else
    data = double(data);
end

if isa(interval, 'datetime')
    data = datenum(datetime);
else
    data = double(data);
end

% data = double(data); interval = double(interval);
data = reshape(data, 1, numel(data)); % force to be column vector

m1 = interval(:,1)<data;
m2 = data<interval(:,2);
exclusive = logical((interval(:,1)<data) .* (data<interval(:,2)));
frontinclusive = logical((interval(:,1)==data) .* 1);
endinclusive = logical(1 .* (data==interval(:,2)));

switch abs(logic)
    
    case 1
        idx_mat = frontinclusive + exclusive + endinclusive;
        
    case 2
        idx_mat = exclusive + endinclusive;
        
    case 3
        idx_mat = frontinclusive + exclusive;
        
    case 4
        idx_mat = exclusive;
                
end

if logic < 0
    idx_mat = ~idx_mat;
end

if size(idx_mat,1) > 1
    idx_vec = logical(sum(idx_mat));
else
    idx_vec = logical(idx_mat);
end

data = data(idx_vec);

end

