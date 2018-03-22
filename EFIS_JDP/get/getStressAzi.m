function [projAzi] = getStressAzi(projLat,projLon)

load('/Users/jpesicek/Dropbox/s6/wsm2008_smoothed.mat')

wlat = extractfield(wsm,'Latitude');
wlon = extractfield(wsm,'Longitude');
wazi = extractfield(wsm,'azimuth');

projAzi = nan(length(projLat),1);
for j=1:length(projLat)
    
    
    dist = zeros(length(wazi),1);
    for i = 1:length(wazi)
        dist(i) = sqrt((wlat(i)-projLat(j))^2 + (wlon(i)-projLon(j))^2);
    end
    
    [~,I] = min(dist);
    projAzi(j) = wazi(I);%
%     disp(['Azimuth: ',num2str(projAzi(j))])
    
end