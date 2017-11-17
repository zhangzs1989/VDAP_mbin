function [XY] = mkGMTsegmentFile(Y,X)

ct=0;

if length(X) > 1
    
    ct = ct + 1;
    XY(ct,1) = {'>'};
    XY(ct,2) = {'-W1,0,--'};
    
    for i=1:length(Y)
        ct=ct+1;
        XY(ct,1) = {Y(i)};
        XY(ct,2) = {X(i)};
    end
else
    XY = [];
end


end