classdef alertLevel
    %ALERTLEVEL Class for handling alert levels
    %   Detailed explanation goes here
    
    properties
        
        schema = alertLevelSchema;
        chron = alertLevelChron;
        
    end
    
    methods
        
        % Create a figure with the color codes, names, and descriptions.
        function plotColorCodeGraphic(obj)
            
        end
        
        function obj = fillNum(obj)
            
            if ~isempty(obj.schema) && ~isempty(obj.str)
                
                for n = 1:numel(obj.schema.str)
                    
                    id = strcmp(lower(obj.str), lower(obj.schema.str{n}));
                    obj.num(id) = obj.schema.num(n);
                    
                end
                
            end
            
        end

        
        % Display information about color code and changes to the command window
        function disp(obj)
            
            disp(obj.schema)
            
            % Display the chronology of alert level changes
            display('  Time Line of Changes: ')
            display('  --------------------')
            for n = 1:numel(obj.chron.tdnum)
                
                display(['     ' datestr(obj.chron.tdnum(n)) ' : (' num2str(obj.chron.num(n)) ') ' obj.str{n}])
                
            end
            display(' ')
            
        end
        
        
        
    end
    
end

