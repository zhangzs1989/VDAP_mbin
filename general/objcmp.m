function lgi = objcmp( obj, prop, val )
%OBJCMP Compares a property/value pair for a vector of objects and returns logical 1
%(true) if the property/value pair matches, and returns logical 0 (false) otherwise.
%
% USAGE:
%
% >> objcmp( allEruptions, 'volcano_name', 'Augustine');
%

%%

% Error handling - This could look prettier than it does, but it will have
% to do for the moment.
if ~isobject( obj )
    
    error_msg = 'The first input argument must be a Matlab object/class.';

    % This should actually go away bc the prop 'max_vei' might actually
    % have multiple values that I want to grab
    if numel(prop)~=numel(val)
        
        error_msg = [error_msg 'The number of input properties must equal the number of input values.'];
        
    end
    
    if numel(prop)>1
       
        error_msg = [error_msg 'This function only handles 1 property.'];
        
    end
    
    error(error_message);

% no initial errors - Try to find the property/value pair    
else
    
    for j = 1:numel(obj)
            
            if sum(strcmp(fieldnames(obj), prop))==0
                error(['Specified class does not contain the field ' prop])
            end
            
            if ischar(val)
            
                lgi = strcmp(get(obj, prop), val);
            
            elseif isnumeric(val)
            
                lgi = get(obj, prop)==val;
                
            end %if ischar(val)
                    
    end
    
end


end % function

