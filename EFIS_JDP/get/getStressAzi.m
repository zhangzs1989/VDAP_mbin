function [projAzi,varargout] = getStressAzi(projLat,projLon,varargin)

srad = 200;
if nargin == 2
    dcut = 0;
elseif nargin == 3
    dcut = varargin{1};
elseif nargin>3
    error('too many inputs')
end
% load('/Users/jpesicek/Dropbox/s6/wsm2008_smoothed.mat')
load('/Users/jpesicek/Dropbox/Research/EFIS/WSM/wsm2016.mat')
wsm = wsm; %for parpool

projAzi = nan(length(projLat),1);

parfor j=1:length(projLat)
    
%     disp(int2str(j))
    [ wsmj ] = filterAnnulusm( wsm, projLat(j), projLon(j), srad); % try to speed things up
    if isempty(wsmj)
        disp(['No point close by, extend radius, ',int2str(j)])
        wsmj = wsm;
    end
    wlon = extractfield(wsmj,'Longitude');
    wlat = extractfield(wsmj,'Latitude');
    wazi = extractfield(wsmj,'AZI');
    wregime = extractfield(wsmj,'REGIME');
    
    dist = zeros(length(wsmj),1);
    for i = 1:length(wsmj)
%         dist(i) = sqrt((wlat(i)-projLat(j))^2 + (wlon(i)-projLon(j))^2);
        [ARCLEN, ~] = distance(wlat(i),wlon(i),projLat(j),projLon(j));
        dist(i) = deg2km(ARCLEN);
    end

    [~,I] = min(dist);
%     projAzi(j) = wazi(I);% this takes the closest one - should I average all close ones instead??
    
    J = (dist<dcut);
    
    if sum(J)>0
        projAzi(j) = mean(wazi(J));
    else
        projAzi(j) = wazi(I);
    end
    
%     disp(['Azimuth: ',num2str(projAzi(j))])
    projRegime{j} = wregime{I};
end

if nargout == 2
    varargout{1} = projRegime;
end

