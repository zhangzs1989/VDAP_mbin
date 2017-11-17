function     [vinfo] = getVolcanoInfo(volcanoCat,vinfo,ii)

%% TODO: add capability to get vinfo based on Vnum or vname also, instead of index
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
vinfo.SHmax= extractfield(volcanoCat(ii),'SHmax');
vinfo.Vnum = volcanoCat(ii).Vnum;
vinfo.type = volcanoCat(ii).GVP_morph_type;
vinfo.tectonic = volcanoCat(ii).tectonic;
vinfo.composition = volcanoCat(ii).composition;
vinfo.country = volcanoCat(ii).country;
vinfo.region = volcanoCat(ii).region;
vinfo.subregion = volcanoCat(ii).subregion;
vinfo.subregion_detail = volcanoCat(ii).subregion_detail;

vinfo.volc_alt_name = volcanoCat(ii).volc_alt_name;
vinfo.feature_names = volcanoCat(ii).feature_names;
vinfo.features_and_alts = volcanoCat(ii).features_and_alts;
vinfo.whelley_vent = volcanoCat(ii).whelley_vent;
vinfo.whelley_morph_type = volcanoCat(ii).whelley_morph_type;

if ~ischar(vinfo.type)
    warning('volcano type is not a char')
    disp(vinfo.type)
    vinfo.type = 'Unknown';
end
if ~ischar(vinfo.tectonic)
    warning('volcano tectonic is not a char')
    disp(vinfo.tectonic)
    vinfo.tectonic = 'Unknown';
end
if ~ischar(vinfo.composition)
    if ~isnan(vinfo.composition)
        warning('weird input volcano composition')
        disp(vinfo.composition)
    end
    vinfo.composition = 'Unknown';
end

%% filter other volcs 
[BufLat, BufLon] = bufferm(vinfo.lat, vinfo.lon, km2deg(50),'outPlusInterior');
[BufLat,BufLon] = flatearthpoly(BufLat,BufLon);
IN = inpolygon(vinfo.Latitude,vinfo.Longitude,BufLat,BufLon);
vinfo.Latitude = vinfo.Latitude(IN);
vinfo.Longitude = vinfo.Longitude(IN);
vinfo.elevs = vinfo.elevs(IN);

end