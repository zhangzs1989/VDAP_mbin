function [ out_catalog ] = filterDepth( in_catalog, depth_range )
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
if isempty(in_catalog)
    out_catalog = in_catalog;
    return
end
% Find the index for all depths below threshold from the catalog
    % subselection
Depth = extractfield(in_catalog, 'Depth');
% id = find(Depth <= max_depth_threshold);
if numel(depth_range)==1
    id = Depth <= depth_range; %JP: improves performance
elseif numel(depth_range)==2
    if depth_range(1) > depth_range(2)
        error('bad input')
    end
    id = Depth <= depth_range(2) & Depth > depth_range(1); %JP: improves performance
else
    error('too many values')
end
    % Subselection of events within time, distance, and depth window
out_catalog = in_catalog(id);


end

