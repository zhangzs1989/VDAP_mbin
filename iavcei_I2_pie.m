function p = iavcei_I2_pie(yes, no)

p = pie([no yes])

if yes==0 && no==0
      
elseif yes==0 && no~=0
    
    p(3).FaceColor = [0 78/255 196/255]
    p(3).LineWidth = 2
    p(1).FaceColor = [221/255 0 0]
    p(1).LineWidth = 2
    p(2).FontSize = 28
    p(4).FontSize = 28
%     p(4).String = sprintf('Yes - %i (%s)', yes, p(4).String)
%     p(2).String = sprintf('No - %i (%s)', no, p(2).String)
    p(4).String = []
    p(2).String = []
    
elseif yes~=0 && no==0
    
    p(1).FaceColor = [0 78/255 196/255]
    p(1).LineWidth = 2

    p(2).FontSize = 28
%     p(2).String = sprintf('Yes - %i (%s)', yes, p(2).String)
    p(2).String = []

    
else
    
    p(3).FaceColor = [0 78/255 196/255]
    p(3).LineWidth = 2
    p(1).FaceColor = [221/255 0 0]
    p(1).LineWidth = 2
    p(2).FontSize = 28
    p(4).FontSize = 28
%     p(4).String = sprintf('Yes - %i (%s)', yes, p(4).String)
%     p(2).String = sprintf('No - %i (%s)', no, p(2).String)
    p(4).String = []
    p(2).String = []

    
end

end