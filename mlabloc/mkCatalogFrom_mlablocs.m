function catalog = mkCatalogFrom_mlablocs(inputs)

% function for reading back in output results and forming catalog struct
D = dir2(inputs.outDir,'Swarm*.txt');
[lonlatdep, ~]= getSwarmStationCoords(inputs.stations);

for l=1:numel(D)
    
    [data,~]=readtext(fullfile(inputs.outDir,D(l).name),' ');
    catalog2(l).Latitude = data{2};
    catalog2(l).Longitude = data{3};
    catalog2(l).Depth = data{4};
    catalog2(l).Misfit = data{5};
    catalog2(l).DateTime = datestr(datenum(data{1},'yyyymmddTHHMMSS.FFF'));
    catalog2(l).Magnitude = [];    
    catalog2(l).ID = D(l).name;
    
    ARCLEN = distance(lonlatdep(:,2),lonlatdep(:,1),catalog2(l).Latitude,catalog2(l).Longitude);
    il = ARCLEN==min(ARCLEN);
    catalog2(l).minDist = deg2km(ARCLEN(il));
    %TODO: 
%     catalog(l).gap = computeMaxStationGap(nlat,nlon,lonlatdep(:,2),lonlatdep(:,1));
%     
%     catalog(l).xerr
%     catalog(l).yerr
%     catalog(l).zerr    
end
catalog=catalog2;

end