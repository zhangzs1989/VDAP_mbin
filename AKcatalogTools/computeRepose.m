% read input eruption file and compute reposes, save new file
clear

startUpLocs.userdir = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/'; %Jeremy's path to the research folder
inputFiles.Eruptions = fullfile(startUpLocs.userdir,'/data/AVOeruptions4.csv'); % JP created this file from Steph's AGU15 eruption chronologies
inputFiles.Intrusions = fullfile(startUpLocs.userdir,'/data/AVOintrusions.csv'); % JP created this file from scratch
AKeruptions = readtext(inputFiles.Eruptions);
AKintrusions = readtext(inputFiles.Intrusions);
outFile = fullfile(startUpLocs.userdir,'/data/AVOeruptions5.csv');
outFile2 = fullfile(startUpLocs.userdir,'/data/AVOintrusions2.csv'); % JP created this file from scratch

% compute repose for each eruption
volcs=unique(AKeruptions(2:end,5));

AKeruptions(1,7) = {'repose (yrs)'};

for j = 1:numel(volcs) % all volcs
    
    I = find(strcmp(AKeruptions(2:end,5),volcs(j))); % all eruptions for volc
    I = I + 1; % account for header line
    
    Estarts = AKeruptions(I,1); % eruption start times
    Estops  = AKeruptions(I,2);
    
    [Y,I2] = sort(datenum(Estarts)); %ensure sorted by time
    yrsInRepose = zeros(numel(Estarts),1);
    AKeruptions(I(I2(1)),7) = {NaN}; % first erupton repose unknown
    
    for k = 2:numel(Estarts) % start at 2 b/c first eruption which we can calculate repose
        
        e2 = Estarts(I2(k)); %eruption
        e1 = Estops(I2(k-1)); % prior eruption
        
        yrsInRepose(k) = (datenum(e2) - datenum(e1))/365;
        AKeruptions(I(I2(k)),7) = {yrsInRepose(k)};
        
    end
    
end

s6_cellwrite(outFile,AKeruptions);
%%
% compute repose for each intrusion
intrudeVolcs = unique(AKintrusions(2:end,4));
volcs2=unique([volcs; intrudeVolcs]);

AKintrusions(1,7) = {'repose (yrs)'};

for j = 2:size(AKintrusions,1)
    
    volcname = AKintrusions(j,4);
    
    I = find(strcmp(AKeruptions(2:end,5),volcname)); % all eruptions for volc
    if ~isempty(I)
        I = I + 1; % account for header line
        
        Estarts = (AKeruptions(I,1)); % eruption start times
        Estops  = AKeruptions(I,2);
        [Y,I2] = sort(datenum(Estarts)); %ensure sorted by time
        yrsInRepose = zeros(numel(Estarts),1);
        
        Istart = datenum(int2str(cell2mat(AKintrusions(j,1))),'yyyymmdd');
        Istop  = datenum(int2str(cell2mat(AKintrusions(j,2))),'yyyymmdd');
        
        II = find(Istart > Y,1,'last');
        
        yrsInRepose(j) = (Istart-Y(II))/365;
        
        AKintrusions(j,7) = {yrsInRepose(j)};
    else
        AKintrusions(j,7) = {NaN};
    end
    
end

s6_cellwrite(outFile2,AKintrusions);