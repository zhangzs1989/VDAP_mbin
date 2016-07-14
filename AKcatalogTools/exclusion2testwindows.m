function test_win = exclusion2testwindows(cat_start, cat_stop, exclude)
%EXCLUSION2TESTWINDOWS Converts a matrix of exlcusion times to the times
% you actually do want to test. If you give it only 1 time, it assumes that
% you want to test everything up to that point.
% NOTE: Requires everything to be in datenum!
% NOTE: Requires inputs to be a single value or in an n-by-2 matrix
% OUTPUT: an n-by-2 matrix

if ~isnumeric(exclude)
   error('Oops... it looks like your data might not be in numeric format.') 
end


if max(size(exclude))>1 % if there is more than one time period to exclude
    
    dates = reshape(exclude',[],1); % reshape into a 1-by-n matrix; use transpose so that the result is in chron order
    dates = [cat_start; dates; cat_stop];
    test_win = reshape(dates,2,[])'; % reshape into a 2-by-n matrix; then use transpose to get back to n-by-2 matrix; must be done in this order to get proper result
    
elseif numel(exclude) == 1 % if there is only one catalog event
    
    test_win = [cat_start datenum(exclude(1))];
    
    
else
    
    test_win = [cat_start cat_stop];
    
end


end