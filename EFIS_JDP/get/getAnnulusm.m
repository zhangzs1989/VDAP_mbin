function [ outer_ann, inner_ann ] = getAnnulusm( lat, lon, distance_km)

%% Set up projection System: Transverse UTM
outer_ann = [nan, nan];
inner_ann = [nan, nan];

try
    % define utm zone and geoid
    utm_zone = utmzone(lat,lon);
    % [ellipsoid, estr] = utmgeoid(utm_zone);
    
    % define matlab structure for utm projection system
    mstruct = defaultm('utm');
    mstruct.zone = utm_zone;
    % mstruct.geoid = almanac('earth','geoid','m',estr);
    mstruct = defaultm(utm(mstruct));
    r = max(distance_km)*1000;
catch
    %% Set up projection System: mercator
    warning('UTM failed, attempting mercator')
    % define matlab structure for utm projection system
    mstruct = defaultm('mercator');
    mstruct.origin = [lat lon 0];
    mstruct = defaultm(mstruct);
    r = km2rad(max(distance_km));
end

%% Project Data

% project data
[x, y] = mfwdtran(mstruct,lat,lon); % central lat long coordinates

%% Filter for outter annulus

angle_range = (0:360)*pi/180; % radians

o_x = x + r*cos(angle_range);
o_y = y + r*sin(angle_range);

[o_lat, o_lon] = minvtran(mstruct, o_x, o_y);
outer_ann = [o_lat', o_lon'];

if length(distance_km) > 1 && min(distance_km) > 0
    
    r = min(distance_km)*1000;
    i_x = x + r*cos(angle_range);
    i_y = y + r*sin(angle_range);
    
    [i_lat, i_lon] = minvtran(mstruct, i_x, i_y);
    inner_ann = [i_lat', i_lon'];
end
%% Check the data by applying inverse projection to the volcano points

% [lat, lon] = minvtran(mstruct, x, y)

end