function     [vinfo] = getVolcanoInfo(volcanoCat,vinfo,ii)

%% TODO: add capability to get vinfo based on Vnum or vname also, instead of index
% add all fields to output line
fn = fieldnames(volcanoCat(ii));
for i=1:numel(fn)
    vinfo.(fn{i}) = volcanoCat(ii).(fn{i});
end
%% extract date times and coords from  catalog for all volcs
vinfo.Latitude = extractfield(volcanoCat,'Latitude');
vinfo.Longitude = extractfield(volcanoCat,'Longitude');
vinfo.elevs = extractfield(volcanoCat,'Elevation');
%% get rid of repeats
vcoords = [vinfo.Latitude' vinfo.Longitude' vinfo.elevs'];
vcoords = unique(vcoords,'rows');
vinfo.Latitude = vcoords(:,1);
vinfo.Longitude = vcoords(:,2);
vinfo.elevs = vcoords(:,3);
%%
vinfo.name = char(extractfield(volcanoCat(ii),'Volcano'));
%     disp([vinfo.name])
%     disp(' ')
vinfo.lat  = extractfield(volcanoCat(ii),'Latitude');
vinfo.lon  = extractfield(volcanoCat(ii),'Longitude');
vinfo.elev = extractfield(volcanoCat(ii),'Elevation');

%% filter other volcs 
[BufLat, BufLon] = bufferm(vinfo.lat, vinfo.lon, km2deg(50),'outPlusInterior');
[BufLat,BufLon] = flatearthpoly(BufLat,BufLon);
IN = inpolygon(vinfo.Latitude,vinfo.Longitude,BufLat,BufLon);
vinfo.Latitude = vinfo.Latitude(IN);
vinfo.Longitude = vinfo.Longitude(IN);
vinfo.elevs = vinfo.elevs(IN);

end