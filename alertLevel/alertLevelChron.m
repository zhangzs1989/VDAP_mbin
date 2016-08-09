classdef alertLevelChron
    %ALERTLEVELCHRON Class for handling alert levels
    %   Detailed explanation goes here
    
    properties
        
        tdnum = []; % datenum for color code change
        str = {}; % string label for each level
        num = []; % numeric label for each level
        schema = alertLevelSchema; % schema relating numeric codes and color
        clr = [];
        
    end
    
    methods
        
        % Create a figure with the color codes, names, and descriptions.
        function plotColorCodeGraphic(obj)
            
        end
        
        function obj = fillNum(obj)
            
            if ~isempty(obj.schema) && ~isempty(obj.str)
                
                for n = 1:numel(obj.schema.level_str)
                    
                    id = strcmp(obj.str, obj.schema.level_str{n});
                    obj.num(id) = obj.schema.level_num(n);
                    
                end
                
            end
            
        end
        
        function obj = fillClr(obj)
            
            if ~isempty(obj.schema) && ~isempty(obj.str)
                
                for n = 1:numel(obj.schema.level_str)
                    
                    for i = 1:numel(obj.str)
                        
                        if strcmp(obj.schema.level_str{n},obj.str{i})
                           
                            obj.clr(i, :) = obj.schema.clr(n, :);
                            
                        end
                        
                        
                    end
                    
                end
                
            end
            
        end

        
        % Display information about color code and changes to the command window
        function disp(obj)
            
            disp(obj.schema)
                        
            % Display the chronology of alert level changes
            display('  Time Line of Changes: ')
            display('  --------------------')
            for n = 1:numel(obj.tdnum)
                
                display(['     ' datestr(obj.tdnum(n)) ' : (' num2str(obj.num(n)) ') ' obj.str{n}])
                
            end
            display(' ')
            
        end
        
        % sorts dates in chronological order (earliest to latest)
        function obj = sort(obj)
            
           [obj.tdnum, SO] = sort(obj.tdnum); % sort the dates and retrieve the sort order
           if ~isempty(obj.str), obj.str = obj.str(SO); end
           if ~isempty(obj.num), obj.num = obj.num(SO); end
           
        end
        
        
        
    end
    
end

