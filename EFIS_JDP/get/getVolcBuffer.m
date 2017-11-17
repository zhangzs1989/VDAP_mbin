function [BufLat, BufLon ] = getVolcBuffer(volcanoCat, kmBuffer, varargin)

%% create polygon with buffer around volcanoes

if nargin ==2 
    
    % Validate argument BUFWIDTH.
    validateattributes(kmBuffer, {'numeric'}, ...
        {'positive','finite','scalar'}, mfilename, 'kmBuffer')
    npts = 13;
    
elseif nargin == 3
    
    npts = varargin{1};
    
    validateattributes(npts, {'numeric'}, ...
        {'positive','finite','scalar'}, mfilename, 'NPTS')
    
else
    warning('Extra variable ignored')
end
%% Need volc coords separated by NaNs here
aLat = nan(numel(volcanoCat)*2,1);
aLon = aLat;

j=0;
for i=1:2:numel(aLat)
    j=j+1;
    aLat(i) = volcanoCat(j).Latitude;
    aLon(i) = volcanoCat(j).Longitude;
end
    

%%
[BufLat, BufLon] = bufferm(aLat,aLon, km2deg(kmBuffer),'outPlusInterior',npts);
[BufLat,BufLon] = flatearthpoly(BufLat,BufLon);

% figure, worldmap('world')
% load coast
% plotm(lat,long)
% plotm(BufLat,BufLon,'k')
% hold on,plotm(latb,lonb,'r')
% geoshow(latb,lonb,'DisplayType','polygon','FaceColor','blue')

% HoloceneVolcBufCoords = [BufLat,BufLon];
% print('HoloceneBufferPoly','-dpng')
% save('HoloceneBufferPoly','HoloceneVolcBufCoords');

