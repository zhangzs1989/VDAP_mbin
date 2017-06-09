function obj = parseMetadata(obj, cellarray)
% store things like the volcano name and the location codes

% loop through each row
for i = 1:numel(cellarray(:, 1))
    
    switch upper(cellarray{i,1})
        
        case upper('VN')
            
            name = upper(strip(cellarray{i, 2}, ' '));
            
        otherwise
            
    end
    
end

obj.VN = name;

end
