function [ out_catalog ] = filterDepth( in_catalog, max_depth_threshold )
%FILTERDEPTH Filters the ANSS catalog to all events shallower than (<=) a
%specified depth
% This function is meant to be used with the ANSS catalog. It is meant to
% be used after the catalog has already been imported and saved as a
% structure.
%
% INPUT:
% - in_catalog = {struct} an ANSS catalog imported to Matlab and stored as a
% structure
% - depth = [double] the maximum depth to be included in the filter results
%
% OUTPUT
% - out_catalog = {struct} a smaller version of the input catalog that is
% filtered to the depth range specified
%
% USAGE
% >> % filter a catalog to events that occurred at or below 20 km
% >> subcatalog = filterDepth( original_catalog, 20);
%
% see also IMPORTANSSCATALOG

% AUTHOR: Jay Wellik, USGS-USAID Volcano Disaster Assistance Program2015-September
% CONTACT: jwellik-usgs.gov; johnwellikii-gmail.com
% DATE: 2015-Sep

%%

% Find the index for all depths below threshold from the catalog
    % subselection
Depth = extractfield(in_catalog, 'Depth');
% id = find(Depth <= max_depth_threshold);
id = Depth <= max_depth_threshold; %JP: improves performance

    % Subselection of events within time, distance, and depth window
out_catalog = in_catalog(id);


end

