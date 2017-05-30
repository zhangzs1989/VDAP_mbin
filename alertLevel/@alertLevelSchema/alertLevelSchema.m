classdef alertLevelSchema
    %ALERTLEVELSCHEMA Schema for alert level changes
    %
    %   PROPERTIES
    %       name    : Name for the Alert Level
    %       level   : n-by-1 cell array of strings - Names for each level
    %       clr     : n-by-3 matrix of RGB triplets corresponding to each
    %                   level
    %   METHODS
    %       alertLevelSchema.predefined( ... )
    %       - CREATES AN ALERTLEVELSCHEMA FROM A PREDEFINED SET OF OPTIONS
    %           OPTIONS INCLUDE
    %           - 'AVO'
    %           - 'PVMBG' | 'CVGHM'
    %           - 'VHP AVIATION'
    %           - 'VHP GROUND'
    %
    
    properties
        
        name; % name of schema
        level; % level label
        clr; % color for plotting
        
    end
    
    methods
        
        % Class constructor
        function obj = alertLevelSchema(name, level, clr)
            
            obj.name = name;
            obj.level = level;
            obj.clr = clr;
            
            verify(obj);
            
        end
        
        % disp over-ride
        function disp(obj)
            
            if ~isempty(obj)
                
                T = table(obj.level, obj.clr, ...
                    'VariableNames', {'level', 'clr'}, ...
                    'RowNames', strsplit(num2str(1:numel(obj.level))));
                disp(T)
                
            end
            
        end
        
        % plot a chart of the color scheme for the alert levels
        function plot(obj)
            
            nlevels = numel(obj.level);
            i = 0;
            for n = nlevels:-1:1
                
                i = i+1;
                ax(n) = subplot(nlevels,1,n); patch([0 0 1 1], [0 1 1 0], obj.clr(i, :))
                ax(n).XTick = []; ax(n).YTick = [];
                ax(n).XLabel.String = obj.level(i);
                ax(n).XLabel.Rotation = 0;
                ax(n).XLabel.FontWeight = 'bold';
                
            end
            title(obj.name)
            
        end
        
        % verify that everything in schema is stored correctly
        function verify(obj)
            
            % color definitions must by n-by-3 matrix of RGB values
            % where n is equal to the number of levels
            if numel(obj.level)~=size(obj.clr, 1)
                warning('Number of levels and number of color definitions must match')
            end
            
            if size(obj.clr, 2)~=3
                warning('Color definitions must be an n-by-3 matrix of RGB values.')
            end
            
        end
        
    end
    
    methods(Static)
        
        function obj = predefined(input)
            
            % color definitions
            std_green = [0 0.7 0.3];
            std_yellow = [1 1 0.4];
            std_orange = [1 0.5 0];
            std_red = [1 0.25 0.25];
            
            obj = alertLevelSchema(input, {'tmp'}, [1 1 1]);
            
            switch upper(input)
                
                case 'AVO'
                    
                    obj.name = 'Alaska Volcano Observatory';
                    obj.level = {'UNASSIGNED'; 'GREEN'; 'YELLOW'; 'ORANGE'; 'RED'};
                    obj.clr = [
                        std_green; ...
                        std_green; ...
                        std_yellow; ...
                        std_orange; ...
                        std_red
                        ];
                    
                case {'PVMBG', 'CVGHM'}
                    
                    obj.name = 'PVMBG/CVGHM - Indonesia';
                    obj.level = {'NORMAL'; 'WASPADA'; 'SIAGA'; 'AWAS'};
                    obj.clr = [
                        std_green; ...
                        std_yellow; ...
                        std_orange; ...
                        std_red
                        ];
                    
                case 'VHP AVIATION'
                    
                    obj.name = 'USGS Volcano Hazards Program - Aviation';
                    obj.level = {'GREEN'; 'YELLOW'; 'ORANGE'; 'RED'};
                    obj.clr = [
                        std_green; ...
                        std_yellow; ...
                        std_orange; ...
                        std_red
                        ];
                    
                case 'VHP GROUND'
                    
                    obj.name = 'USGS Volcano Hazards Program - Ground';
                    obj.level = {'NORMAL'; 'ADVISORY'; 'WATCH'; 'WARNING'};
                    obj.clr = [
                        std_green; ...
                        std_yellow; ...
                        std_orange; ...
                        std_red
                        ];
                    
                case 'CVO PRE-1980'
                    
                    
                otherwise
                    
            end
        end
    end
    
end