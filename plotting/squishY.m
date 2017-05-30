function ax = squishY( ax )
%SQUISHY Removes vertical space between subplot axes

miny = ax(1).Position(2);
maxy = ax(end).Position(2) + ax(end).Position(4);

% axis height == total height taken up by all axes divided by number of axes
ah = (maxy-miny)/numel(ax);

ax(1).Position(4) = ah;
for n = 2:numel(ax)
   
   ax(n).Position(2) = ax(n-1).Position(2) + ax(n-1).Position(4);
   ax(n).Position(4) = ah;
   ax(n).XTick = [];
    
end

end

