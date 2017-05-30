function [ out_catalog ] = filterByNetworkCode( in_catalog, netCodes )
%FILTERBYNETWORKCODE Filters an ANSS catalog by network code.
% NOTE: Known issues when providing multiple networks. Further tests needed
% for improvement.
%
% INPUT:
% - in_catalog = {struct} an ANSS catalog imported to Matlab and stored as a
% structure
% - netCodes = [struct} string inside structure of the network code (e.g.,
% 'AV')
%
% OUTPUT
% - out_catalog = {struct} a smaller version of the input catalog that is
% filtered to exclude other network codes other than those in netCodes
%
% USAGE
% >> % filter a catalog to events located by AV network only
% >> subcatalog = filterTime( original_catalog,{'AV' 'AK'});
%
% see also IMPORTANSSCATALOG

% AUTHOR: JP, USGS-USAID Volcano Disaster Assistance Program2015-Nov
% CONTACT: jwellik-usgs.gov; johnwellikii-gmail.com
% DATE: 2015-Nov

% JP: relies on structfind function downloaded from mathworks user contributed
% stuff 

allneti = [];

for i=1:length(netCodes)
    
    neti = structfind(in_catalog,'Source',netCodes(i));
    allneti = [allneti neti];
    
end

allneti = sort(allneti);

    % Subselection of data within the time window
out_catalog = in_catalog(allneti);

end

