function E = importEruptionsFromSteph2(filename)
% IMPORTERUPTIONSFROMSTEPH2
% read in the data file I made from Stephs AGU data and get eruption
% windows to match old version
% J. PESICEK, MARCH 2016
% modified J. WELLIK, AUGUST 2016
%
% SP info:
% eruption onset end VEI monitoring/forecast
%
% filename should be a csv with the following columns (including a header row)
% 1st column: [] start
% 2nd column: [] stop
% 3rd column: [] maximum VEI (VEI 0 means non assigned)
% 4th column: [] -1:no network, 1:forecast; 0:not forecast; 2:unclear
% 5th column: {} volcano name
%

%%

eruptions = readtext(filename); % Stephanie's file is an n-by-5 cell matrix of eruption info
% see function help for details

n = 0; % number of eruption
for i = 2:numel(eruptions(:,1)); % Stephanie's file has headers in row 1
    
    n = n+1;
    E(n) = ERUPTION;
    E(n).volcano_name = eruptions{i, 5};
    E(n).start = eruptions{i, 1};
    E(n).stop = eruptions{i, 2};
    E(n).max_vei = eruptions{i, 3};
    E(n).forecastyn = eruptions{i, 4};
    
end


end