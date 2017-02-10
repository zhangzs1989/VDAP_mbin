function dn = decyear2date( decyear )
% DECYEAR2DN Converts a decimal year to a datenum
%   Take leap years into account

% Jay Wellik, USGS-VDAP, February 10, 2017

year=fix(decyear);
day=decyear-year;
daysinyear = datenum(num2str(year+1), 'yyyy') -  datenum(num2str(year), 'yyyy');
dn = datetime(datevec(datenum(year,1,1)+day.*daysinyear));

end
