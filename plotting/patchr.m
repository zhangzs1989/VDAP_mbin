function p = patchr( x, y, varargin )
%PATCH2 Creates a rectangular patch with simplified inputs
% X     : [n-by-2 vector of xmin and xmax of each rectangle
% Y     : [n-by-2 vector of ymin and ymax for each rectangle

warning('This script has been renamed to PATCH2. PATCHR will soon be removed. Please switch usage to PATCH2.')

warning('This only works for one patch at a time right now.')
p = patch('XData', [x(:,1) x(:,2) x(:,2) x(:,1)], 'YData', [y(:,1) y(:,1) y(:,2) y(:,2)], varargin{:});

end

