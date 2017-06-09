function val = sumtypes( obj, types )
%SUMTYPES Yields daily sums across multiple event types
% Result is an n-by-1 vector, where n is the length of the table in the
% JMAVEQ object
%
% USAGE
% >> allBtypes = sumtypes(V, {'B' 'BH' 'BL' 'BT' 'BS'})
%
% The previous statement has the same effect as
% >> allBtypes = sum(V.C{:, {'B' 'BH' 'BL' 'BT' 'BS'}}, 2)
%
% SEE ALSO table

val = sum(obj.C{:, types}, 2);

end

