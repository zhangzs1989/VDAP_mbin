function A = createSchema( varargin )
%PREDEFSCHEMA Creates an alertLevelSchema object based on pre-defined
%settings
%   Detailed explanation goes here

%%

A = alertLevelSchema;

if nargin > 0
    
    input = varargin{1};
    
    switch upper(input)
        
        case 'AVO'
            
            A.name = 'Alaska Volcano Observatory';
            A.level_str = {'UNASSIGNED'; 'GREEN'; 'YELLOW'; 'ORANGE'; 'RED'};
            A.level_num = [0 1 2 3 4];
            A.clr = [
                0 0.7 0.3; ...
                0 0.7 0.3; ...
                1 1 0.4; ...
                1 0.5 0; ...
                1 0.25 0.25
                ];
            
        case {'PVMBG', 'CVGHM'}
            
            A.name = 'PVMBG - Indonesia';
            A.level_str = {'NORMAL'; 'WASPADA'; 'SIAGA'; 'AWAS'};
            A.level = [1 2 3 4];
            A.clr = [
                0 0.7 0.3; ...
                1 1 0.4; ...
                1 0.5 0; ...
                1 0.25 0.25
                ];
            
        case 'VHP AVIATION'
            
            A.name = 'USGS Volcano Hazards Program - Aviation';
            A.level_str = {'GREEN'; 'YELLOW'; 'ORANGE'; 'RED'};
            A.level = [1 2 3 4];
            A.clr = [
                1 1 0.4; ...
                1 0.5 0; ...
                1 0.25 0.25
                ];
            
            
        case 'VHP GROUND'
            
            A.name = 'USGS Volcano Hazards Program - Ground';
            A.level_str = {'NORMAL'; 'ADVISORY'; 'WATCH'; 'WARNING'};
            A.level = [1 2 3 4];
            A.clr = [
                1 1 0.4; ...
                1 0.5 0; ...
                1 0.25 0.25
                ];
            
        case 'CVO PRE-1980'
            
            
        otherwise
            
            
    end
    
end

end

