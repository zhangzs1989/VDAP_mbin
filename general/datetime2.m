function output = datetime2( input )
%DATETIME2 Converts datenums to datetimes but preserves the size of the
%input matrix. Currently only works with n-by-m sized matrices.
% This allows you to skip the syntactic step of
% datetime(datestr(...)) that is required with the default datetime class.
%
% USAGE
% Compare the results from this:
% >> dt = datetime2([now-40 now-30; now-20 now-10])
% 
% with the results from this:
% >> dt = datetime(datestr([now-40 now-30; now-20 now-10]))

output = NaT(size(input));

for n = 1:size(input,2) % for the number of columns

    output(:,n) = datetime(datestr(input(:,n))); % convert datenum to datetime

end

end

