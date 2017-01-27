function data = removesunglint( data )
%REMOVESUNGLINT Removes entries that are candidates for sun-glint
%contamination
%   Removes pixels with a sun-glint angle of < 12o
%   See http://modis.higp.hawaii.edu/contents.html for more info

%%

data(:, data.Glint < 12) = [];

end

