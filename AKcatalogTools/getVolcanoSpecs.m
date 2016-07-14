function vinfo = getVolcanoSpecs(volcname,inputFiles,params)

% sloppy, tidy up later

% get volc coords
volcLocs=readtext(inputFiles.volcLocs);
for i=1:size(volcLocs,1)
    TF = strcmp(volcname,volcLocs(i,2));
    if TF
        break
    end
end
% disp(volcLocs(i,2))
vcoords=cell2mat(volcLocs(2:end,3:5));
volc=vcoords(i-1,:);

vlat=volc(1); vlon = volc(2); 

velev = -volc(3)/1000;

% check for uniqueness b/c Atka and Korovin have same coords in AVO list
im = find(vcoords(:,1)==vlat & vcoords(:,2)==vlon);
im2 = (im~=(i-1));
im = im(im2);

iss=isspace(volcname);
if sum(iss) > 0
    sp = find(iss==1);
    vname=volcname([1:sp-1,sp+1:end]);
else
    vname=volcname;
end

vinfo.name = vname;
vinfo.lat = vlat;
vinfo.lon = vlon;
vinfo.elev = velev;
vinfo.vcoords = vcoords;
vinfo.im = im;

% now determine volcano summits within annulus
if numel(params.srad) == 1
    srad = params.srad;
else
    srad = params.srad(2);
end

[vlatann, vlonann] = bufferm(vinfo.lat, vinfo.lon, srad/111, 'out', 50);
in = inpolygon(vinfo.vcoords(:,2), vinfo.vcoords(:,1), vlonann, vlatann);
in(vinfo.im) = false;
vlats = vinfo.vcoords(in,1); vlons = vinfo.vcoords(in,2); elevs = vinfo.vcoords(in,3);

vlati = vinfo.lat==vlats;
vloni = vinfo.lon==vlons;
if sum(vlati ~= vloni)>0; warning('coord mismatch'); end

vinfo.vlats = vlats;
vinfo.vlons = vlons;
vinfo.velevs= elevs;