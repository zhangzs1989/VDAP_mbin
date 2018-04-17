function catalog2gmt(catalog,outFile)


Y = extractfield(catalog,'Latitude');
X = extractfield(catalog,'Longitude');

try
    Depth = extractfield(catalog,'Depth');
catch
    Depth = -extractfield(catalog,'Elevation')/1000;
end

try
    dts = datenum(extractfield(catalog,'DateTime'));
end
try
    Magnitude = extractfield(catalog,'Magnitude');
end

ct = 0;
for i=1:length(Y)
    ct=ct+1;
    figData(ct,1) = {X(i)};
    figData(ct,2) = {Y(i)};
    figData(ct,3) = {Depth(i)};
    try
        figData(ct,4) = {datestr(dts(i),'yyyy-mm-ddTHH:MM:SS')};
        figData(ct,5) = {Magnitude(i)};
    end
end

s6_cellwrite(outFile,figData)

end