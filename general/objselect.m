function obj2 = objselect( obj, prop, val )
%OBJSELECT Returns the subset of obj that have the matching property/value
%pair. Uses objcmp to complete the return.
%
% see also objcmp
%

%%

obj2 = obj(objcmp( obj, prop, val));

end

