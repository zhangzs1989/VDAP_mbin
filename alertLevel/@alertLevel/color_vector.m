function clr = color_vector( obj )
%COLOR_VECTOR Creates an n-by-3 matrix of colors for each alert level
%change in obj.date and obj.level

%%

clr = zeros(numel(obj.level), 3); % pre-allocate size

for n = 1:numel(obj.level)
    
    clr(n, :) = obj.schema.clr(obj.level(n), :);
    
end

end

