function mkKMLfileFromCatalog(catalog,fname)

lat=extractfield(catalog,'Latitude');
lon=extractfield(catalog,'Longitude');
dep=extractfield(catalog,'Depth');
mag=extractfield(catalog,'Magnitude');
time=extractfield(catalog,'DateTime');
mag(mag==0) = 0.001;
I = ~isnan(mag);
lat = lat(I);
lon = lon(I);
dep = dep(I);
mag = mag(I);
time = time(I);

%this could use some work
scale = (mag+1.2)./2;
scale = 1.2; % default google scale

description = cell(length(lat),1);
for i=1:length(lat)
    description{i} = sprintf('%s, Mag = %4.2f, Depth = %4.2f',char(time(i)),mag(i),dep(i));
end

% doesn't work on "matlab -nodisplay", not sure why
kmlwrite(fname,lat,lon,dep*-1000,'Name','',...
    'AltitudeMode','relativeToSeaLevel',...
    'IconScale',scale,'Description',description,...
    'icon','/Users/jpesicek/Dropbox/VDAP/EFIS/placemark_circle.png')




end