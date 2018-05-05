function [mapData] = mkGMTxyFile(Y,X,Depth,DateTime)
ct = 0;

if ~isempty(Depth) && ~isempty(DateTime)
    
    for i=1:length(Y)
        ct=ct+1;
        mapData(ct,1) = {Y(i)};
        mapData(ct,2) = {X(i)};
        mapData(ct,3) = {datestr(DateTime(i),'yyyy-mm-ddTHH:MM:SS')};
        mapData(ct,4) = {Depth(i)};
    end
    
else % for case where X is date. TODO: generalize
    
    for i=1:length(Y)
        ct=ct+1;
        mapData(ct,2) = {Y(i)};
        mapData(ct,1) = {X(i,:)};
    end
    
end

end