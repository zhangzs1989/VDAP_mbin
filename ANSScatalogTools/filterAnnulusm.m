function [ out_catalog, outer_ann, inner_ann ] = filterAnnulusm( in_catalog, lat, lon, distance_km)
%FILTERANNULUS Filters earthquakes within a radius of n kilometers
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
% - distance_km = [double] or [2x1 double] the radial distance in km over which to search
%       - include two values (e.g., [2, 45] to define a donut shape in which to search
%
% OUTPUT
% - out_catalog = {struct} a smaller version of the input catalog that is
% filtered to events that occured within the defined annulus
% - outer_ann = [nx2 double] the latitude and longitude coordinates defining the outer annulus
% - inner_ann = [nx2 double] the latitude and longitude coordinates defining the inner annulus
%
% USAGE
% >> % filter a catalog to events that occurred within 50 km of a given point
% >> [subcatalog, outer, inner] = filterAnnulusm(original_catalog, 56, -153, 50));
% >>
% >> % filter a catalog to events between 2 and 45 km of a given point
% >> [subcatalog, outer, inner] = filterAnnulusm(original_catalog, 56, -153, [2 45]);
%
% see also IMPORTANSSCATALOG FILTERDEPTH FILTERTIME MAPPINGTOOLBOX

% AUTHOR: Jay Wellik, USGS-USAID Volcano Disaster Assistance Program
% CONTACT: jwellik-usgs.gov; johnwellikii-gmail.com
% DATE: 2015-Sep

% UPDATES:
% 2015-Oct-21 - Change to use mapping toolbox and filter in UTM coordinates

%%

out_catalog = in_catalog;
outer_ann = [nan, nan];
inner_ann = [nan, nan];



%% Set up projection System: Transverse UTM
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
%% retrieve earthquake lat & long from catalog

elon = extractfield(in_catalog, 'Longitude');
elat = extractfield(in_catalog, 'Latitude');


%% Project Data

% project data
[x, y] = mfwdtran(mstruct,lat,lon); % central lat long coordinates
[ex, ey] = mfwdtran(mstruct,elat,elon);

%% Filter for outter annulus

angle_range = (0:360)*pi/180; % radians

o_x = x + r*cos(angle_range);
o_y = y + r*sin(angle_range);

id = inpolygon(ex, ey, o_x, o_y);

try
    out_catalog = in_catalog(id);
catch % addition for filtering non standard catalogs but with lat/lon fields (i.e. volcano coords)
    warning('structure not of catalog type, may not filter all fields')
    NAMES = char(fieldnames(in_catalog));
    for i=1:size(NAMES,1)
        tmp = getfield(in_catalog,NAMES(i,:));
        if length(tmp)==length(id)
            out_catalog = setfield(out_catalog,NAMES(i,:),tmp(id));
        end
    end
end

[o_lat, o_lon] = minvtran(mstruct, o_x, o_y);
outer_ann = [o_lat', o_lon'];


%% Filter for inner annulus

if length(distance_km) > 1 && min(distance_km) > 0
    
    r = min(distance_km)*1000;
    i_x = x + r*cos(angle_range);
    i_y = y + r*sin(angle_range);
    
    id2 = ~inpolygon(ex(id), ey(id), i_x, i_y);
    
    try
        out_catalog = out_catalog(id2);
    catch
        warning('structure not of catalog type, may not filter all fields')
        NAMES = char(fieldnames(in_catalog));
        for i=1:size(NAMES,1)
            tmp = getfield(in_catalog,NAMES(i,:));
            if length(tmp)==length(id2)
                out_catalog = setfield(out_catalog,NAMES(i,:),tmp(id2));
            end
        end
    end
    [i_lat, i_lon] = minvtran(mstruct, i_x, i_y);
    inner_ann = [i_lat', i_lon'];
    
end

%% Check the data by applying inverse projection to the volcano points

% [lat, lon] = minvtran(mstruct, x, y)



end