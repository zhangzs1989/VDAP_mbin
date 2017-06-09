function obj = parseMetadata( obj, metadata )
%PARSEDATA Parse data for JMAVCAT
%
% INPUT
%   obj         : JMAVCAT object
%   metadata    : cell array containing metadata
%

% metadata cell array, e.g.:
%{
metadata =
  1×35 cell array
  Columns 1 through 30
    'VN'    'Atosanupuri'    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''    ''
  Columns 31 through 35
    ''    ''    ''    ''    ''
%}

%%

% loop through each row
for i = 1:numel(metadata(:, 1))
    
    switch upper(metadata{i,1})
        
        case upper('VN')
            
            name = upper(strip(metadata{i, 2}, ' '));
            
        otherwise
            
    end
    
end

obj.VN = name;

end

