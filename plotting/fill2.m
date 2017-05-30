function h = fill2( x, y, c )
%FILL2 Creates a rectangular patch with simplified inputs
% X     : [n-by-2 vector of xmin and xmax of each rectangle
% Y     : [n-by-2 vector of ymin and ymax for each rectangle

% THIS:
% x =
%      1     5
%      7    10
%     13    16
%
% GETS TRANSFORMED TO THIS:
% x2 =
%      1     7    13
%      1     7    13
%      5    10    16
%      5    10    16
% 
% AND THIS:
% y =
%      0     1
%      0     1
%      0     1
%
% GETS TRANSFORMED TO THIS:
% y2 =
%      0     0     0
%      1     1     1
%      1     1     1
%      0     0     0


% warning('This only works for one patch at a time right now.')
% p = patch('XData', [x(:,1) x(:,2) x(:,2) x(:,1)], 'YData', [y(:,1) y(:,1) y(:,2) y(:,2)], varargin{:});

x2(:, 1) = x(:, 1);
x2(:, 2) = x(:, 1);
x2(:, 3) = x(:, 2);
x2(:, 4) = x(:, 2);
x2 = x2';

y2 = [y'; flipud(y')];

for n = 1:size(x2,2)
    h(n) = fill(x2(:,n), y2(:,n), c(:,n)'); hold on
end
    
end

