function [ out_catalog ] = filterMag( in_catalog, mag )
%FILTERDEPTH Filters the ANSS catalog to all events shallower than (<=) a
%specified depth
% This function is meant to be used with the ANSS catalog. It is meant to
% be used after the catalog has already been imported and saved as a
% structure.
%
% INPUT:
% - in_catalog = {struct} an ANSS catalog imported to Matlab and stored as a
% structure
% - Magnitude = [double] or [2x1 double] the minimum value over which to search
%       - include two values (e.g., [2, 45] to define min and max to search
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
if ~isempty(in_catalog)
    % Find the index for all depths below threshold from the catalog
    % subselection
    Mags = extractfield(in_catalog, 'Magnitude');
    % id = find(Mag >= min_mag);
    if length(mag) == 1
        id = Mags >= mag;
    else
        id = Mags >= min(mag) & Mags < max(mag);
    end
    % Subselection of events within time, distance, and depth window
    % out_catalog = in_catalog(id);
    out_catalog = in_catalog(id);
else
    out_catalog = in_catalog;
end
    
end

