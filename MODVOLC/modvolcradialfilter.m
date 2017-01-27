function data = modvolcradialfilter( data, lat, lon, km )
%MODVOLCRADIALFILTER Filters data based on radial search of KM kms from pt LAT LON
%   Requires the Mapping Toolbox

%%

lat_vec = zeros(size(data.Latitude))+lat;
lon_vec = zeros(size(data.Longitude))+lon;

[arclen, ~] = distance(data.Latitude, data.Longitude, lat_vec, lon_vec);

arckm = deg2km(arclen);
idx = arckm < km;

data(~idx, :) = [];

end

