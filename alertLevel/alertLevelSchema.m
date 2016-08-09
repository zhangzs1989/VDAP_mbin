classdef alertLevelSchema
    %ALERTLEVELSCHEMA Schema for alert level changes
    %   Detailed explanation goes here
    
    properties
        
        name = 'Empty Alert Level Schema'; % name of schema
        level_str; % level label
        level_num; % numeric level
        description = {}; % descriptions corresponding to each alert level
        clr; % color for plotting
        
    end
    
    methods
        
        function disp(obj)
            
            if ~isempty(obj)
                
                % Display the schema
                display(['  Color Code Schema: (' obj.name ')'])
                display( '  ------------------')
                for n = 1:numel(obj.level_str)
                    
                    display(['     (' num2str(obj.level_num(n)) ') ' upper(obj.level_str{n}) ''])
                    
                end
                display(' ')
                
            end
            
        end
        
    end
    
end

