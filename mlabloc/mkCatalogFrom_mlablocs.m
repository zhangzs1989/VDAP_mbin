function catalog = mkCatalogFrom_mlablocs(inputs)

% function for reading back in output results and forming catalog struct
D = dir2(inputs.outDir,'Swarm*.txt');
[lonlatdep, ~]= getSwarmStationCoords(inputs.stations);

for l=1:numel(D)
    
    [data,~]=readtext(fullfile(inputs.outDir,D(l).name),' ');
    catalog(l).Latitude = data{2};
    catalog(l).Longitude = data{3};
    catalog(l).Depth = data{4};
    catalog(l).Misfit = data{5};
    catalog(l).DateTime = datestr(datenum(data{1},'yyyymmddTHHMMSS.FFF'));
    catalog(l).Magnitude = [];    
    catalog(l).ID = D(l).name;
    
    ARCLEN = distance(lonlatdep(:,2),lonlatdep(:,1),catalog(l).Latitude,catalog(l).Longitude);
    il = ARCLEN==min(ARCLEN);
    catalog(l).minDist = deg2km(ARCLEN(il));
    catalog(l).gap = computeMaxStationGap(catalog(l).Latitude,catalog(l).Longitude,lonlatdep(:,2),lonlatdep(:,1));

    %TODO: 
%     catalog(l).xerr
%     catalog(l).yerr
%     catalog(l).zerr    
end

end