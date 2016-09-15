function [eruption_windows] = getEruptionsFromSteph(volcname,AKeruptions,minVEI,mcode)

% read in the data file I made from Stephs AGU data and get eruption
% windows to match old version
% J. PESICEK, MARCH 2016

% SP info:
%eruption onset end VEI monitoring/forecast
%VEI 0 means non assigned
%4th column: -1:no network, 1:forecast; 0:not forecast; 2:unclear


eruption_windows = [];

if mcode % get only seismically monitored ones
    
    
    for i=2:size(AKeruptions,1)
        
        TF = strcmp(volcname,char(AKeruptions(i,5)));
        % disp(char(AKeruptions(i,5)))
        
        if TF
            
            if cell2mat(AKeruptions(i,4)) ~= -1 && cell2mat(AKeruptions(i,3)) >= minVEI %has seismic network and VEI > X
                
                eruption_windows = [eruption_windows; datenum(cell2mat(AKeruptions(i,1))) datenum(cell2mat(AKeruptions(i,2))) cell2mat(AKeruptions(i,3)) cell2mat(AKeruptions(i,6)) cell2mat(AKeruptions(i,7))];
                
            end
        end
        
    end
    
    
else % get all eruptions, not just seismically monitored ones
    
    for i=2:size(AKeruptions,1)
        
        TF = strcmp(volcname,char(AKeruptions(i,5)));
        % disp(char(AKeruptions(i,5)))
        
        if TF
            
            if cell2mat(AKeruptions(i,3)) >= minVEI % VEI > X
                
                eruption_windows = [eruption_windows; datenum(cell2mat(AKeruptions(i,1))) datenum(cell2mat(AKeruptions(i,2))) cell2mat(AKeruptions(i,3)) cell2mat(AKeruptions(i,6)) cell2mat(AKeruptions(i,7))];
                
            end
        end
        
    end
    
end

eruption_windows = sortrows(eruption_windows);


end