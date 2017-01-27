function [obj2, idx] = objselect( obj, prop, val )
%OBJSELECT Returns the subset of obj that have the matching property/value
%pair. Uses objcmp to complete the return.
%
% see also objcmp
%

%%

allvalues = get(obj, prop); % all values for the specified property
lgc = ismember(allvalues, val); % logical array of matches
obj2 = obj(lgc); % extract matched objects
idx = find(lgc); % index of matches

% obj2 = obj(objcmp( obj, prop, val));

end

