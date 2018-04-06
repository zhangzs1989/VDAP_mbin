function catalog2gmt(catalog,outFile)


Depth = extractfield(catalog,'Depth');
Y = extractfield(catalog,'Latitude');
X = extractfield(catalog,'Longitude');

if numel(fieldnames(catalog)) > 3
    dts = datenum(extractfield(catalog,'DateTime'));
    Magnitude = extractfield(catalog,'Magnitude');
end

ct = 0;
for i=1:length(Y)
    ct=ct+1;
    mapData(ct,1) = {X(i)};
    mapData(ct,2) = {Y(i)};
    mapData(ct,3) = {Depth(i)};
    try
        mapData(ct,4) = {datestr(dts(i),'yyyy-mm-ddTHH:MM:SS')};
        mapData(ct,5) = {Magnitude(i)};
    end
end

s6_cellwrite(outFile,mapData)

end