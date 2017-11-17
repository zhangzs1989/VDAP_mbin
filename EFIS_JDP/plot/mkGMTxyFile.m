function [mapData] = mkGMTxyFile(Y,X,Depth,DateTime)


ct = 0;
for i=1:length(Y)
    ct=ct+1;
    mapData(ct,1) = {Y(i)};
    mapData(ct,2) = {X(i)};
    mapData(ct,3) = {datestr(DateTime(i),'yyyy-mm-ddTHH:MM:SS')};
    mapData(ct,4) = {Depth(i)};
end

end