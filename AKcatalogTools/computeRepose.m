% read input eruption file and compute reposes, save new file
clear

startUpLocs.userdir = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/'; %Jeremy's path to the research folder
inputFiles.Eruptions = fullfile(startUpLocs.userdir,'/data/AVOeruptions4.csv'); % JP created this file from Steph's AGU15 eruption chronologies 
AKeruptions = readtext(inputFiles.Eruptions);
outFile = fullfile(startUpLocs.userdir,'/data/AVOeruptions5.csv');

% compute repose for each eruption
volcs=unique(AKeruptions(2:end,5));

AKeruptions(1,7) = {'repose (yrs)'};

for j = 1:numel(volcs) % all volcs
       
    I = find(strcmp(AKeruptions(2:end,5),volcs(j))); % all eruptions for volc
    I = I + 1; % account for header line
    
    Estarts = AKeruptions(I,1); % eruption start times
    [Y,I2] = sort(datenum(Estarts)); %ensure sorted by time
    yrsInRepose = zeros(numel(Estarts),1);
    AKeruptions(I(I2(1)),7) = {NaN}; % first erupton repose unknown

    for k = 2:numel(Estarts) % start at 2 b/c first eruption which we can calculate repose
        
        e2 = Estarts(I2(k)); %eruption 
        e1 = Estarts(I2(k-1)); % prior eruption
        
        yrsInRepose(k) = (datenum(e2) - datenum(e1))/365;   
        AKeruptions(I(I2(k)),7) = {yrsInRepose(k)};
    
    end
    
end

s6_cellwrite(outFile,AKeruptions);