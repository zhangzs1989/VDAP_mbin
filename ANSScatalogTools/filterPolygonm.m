function [ out_catalog ] = filterPolygonm( in_catalog, polylons, polylats)
%FILTERPOYGONM Filters earthquakes within a polygon
% This function is meant to be used with the ANSS catalog. It is meant to
% be used after the catalog has already been imported and saved as a
% structure.
% DEPENDENCIES: Matlab Mapping Toolbox
%
% INPUT:
% - in_catalog = {struct} an ANSS catalog imported to Matlab and stored as a
% structure
% - lat = [double] latitude of the point to search around
% - lon = [double] longitude of the point to search around

%
% OUTPUT
% - out_catalog = {struct} a smaller version of the input catalog that is
% filtered to events that occured within the defined annulus

%
% USAGE
% >> % filter a catalog to events that occurred within 50 km of a given point
% >> [subcatalog, outer, inner] = filterAnnulusm(original_catalog, [lon1 lat1; lon2 lat2]);
% >>

%
% see also IMPORTANSSCATALOG FILTERDEPTH FILTERTIME MAPPINGTOOLBOX

% AUTHOR: J. Pesicek, USGS-USAID Volcano Disaster Assistance Program
% DATE: 2016-June

% UPDATES:
% 2015-Oct-21 - Change to use mapping toolbox and filter in UTM coordinates

%%

out_catalog = in_catalog;
lat = polylats;
lon = polylons;

%% Set up projection System: Transverse UTM

    % define utm zone and geoid
utm_zone = utmzone(mean(lat),mean(lon));
[ellipsoid, estr] = utmgeoid(utm_zone);

    % define matlab structure for utm projection system
mstruct = defaultm('utm');
mstruct.zone = utm_zone;
% mstruct.geoid = almanac('earth','geoid','m',estr);
mstruct = defaultm(utm(mstruct));

%% retrieve earthquake lat & long from catalog

elon = extractfield(in_catalog, 'Longitude');
elat = extractfield(in_catalog, 'Latitude');


%% Project Data

    % project data
[x, y] = mfwdtran(mstruct,lat,lon); % central lat long coordinates
[ex, ey] = mfwdtran(mstruct,elat,elon);

%% Filter for outter annulus

% angle_range = (0:360)*pi/180; % radians
% r = max(distance_km)*1000;
% 
% o_x = x + r*cos(angle_range);
% o_y = y + r*sin(angle_range);

id = inpolygon(ex, ey, x, y);
out_catalog = in_catalog(id);

% [o_lat, o_lon] = minvtran(mstruct, o_x, o_y);
% outer_ann = [o_lat', o_lon'];


% %% Filter for inner annulus
% 
% if length(distance_km) > 1 && min(distance_km) > 0
% 
%     r = min(distance_km)*1000;
%     i_x = x + r*cos(angle_range);
%     i_y = y + r*sin(angle_range);
% 
%     id2 = ~inpolygon(ex(id), ey(id), i_x, i_y);
% 
%     out_catalog = out_catalog(id2);
% 
%     [i_lat, i_lon] = minvtran(mstruct, i_x, i_y);
%     inner_ann = [i_lat', i_lon'];
% 
% end
% 
% %% Check the data by applying inverse projection to the volcano points
% 
% % [lat, lon] = minvtran(mstruct, x, y)
% 
% 

end