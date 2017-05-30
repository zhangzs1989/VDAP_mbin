function date = incmonth( date, varargin )
%INCMONTH Increments a datenum or datestr by n months
% Return value is of the same type as input type. I.e., if you supply a
% datenum, the return is a datenum. If you supply a datestr, the return is
% a datestr.
%
% USAGE
% >> a = incmonth('2015/12/01') % increments date by 1 month (default)
%
% >> b = incmonth('2015/12/01', 2) % increments date by 2 months
%

%%

dv = datevec(date);

if nargin > 1
    dv(2) = dv(2) + varargin{1};
else   
    dv(2) = dv(2) + 1;
end

if ischar(date)
    date = datestr(dv);
elseif isnumeric(date)
    date = datenum(dv);
else
    error('Unknown error.')
end
    
end

