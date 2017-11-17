function [topoOut] = mkGMTtopoFile(RA, ZA)

topoOut = zeros(RA.RasterSize(1)*RA.RasterSize(2),3);
tct=0;
for i=1:RA.RasterSize(1)
    ii = RA.LatitudeLimits(2)-(i-1)*RA.CellExtentInLatitude;
    for j=1:RA.RasterSize(2)
        jj = RA.LongitudeLimits(1)+(j-1)*RA.CellExtentInLongitude;
        tct = tct + 1;
        topoOut(tct,1:3) = [ii jj double(ZA(i,j))];
    end
end


end