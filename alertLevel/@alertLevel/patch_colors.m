function pc = patch_colors( obj )
%PATCH_COLORS Creates a n-by-1-by-3 matrix of colors corresponding to each
%alert level change that can be used with alertLevel.PLOT, which uses the
%PATCH2 function. See the PATCH documentation to see why the RGB triplets
%need to be in a n-by-1-by-3 matrix.
% See PATCH

pc = zeros(numel(obj.level), 1, 3);

c = obj.color_vector;
for n = 1:size(c,1)

   pc(n,1,:) = c(n, :); 
    
end

end

