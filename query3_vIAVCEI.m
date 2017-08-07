%% Repose and Time to Eruption for M4s
%{
How often are M4s followed by another explosion when the volcano has been
in repose for less than n days?

Scatter plot of x = 'Time since Last Eruption' and y = 'Time to Next
Eruption' for all M4s
%}

load('/Users/jjw2/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/LOG.mat')
OLOG = LOG;

vdict = readtable('/Users/jjw2/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/vdict.txt', 'Delimiter', ',')

%%

% TESTLOG reduces the entire LOG to just one entry per voclano
TESTLOG = LOG(LOG.annulus(:,1)==0 & LOG.annulus(:,2)==30 & LOG.t_window(:,1)==1 & LOG.t_window(:,2)==30 & LOG.use_triggers==0, :);

c = colormap('lines');

% First 4 options search the entire repose period; 5 and beyond only search
% up to n days before the next eruption
% v_desc = {'Preceding Max Magnitude'; 'Preceding Cum. Magnitude'; 'Preceding Counts'; 'EQ Rate'; ...
%     'Preceding n days Max Magnitude'; 'Preceding n days Cum Magnitude'; 'Prec. n days Counts'};
% v = 1;

f = figure;

P_ = [];
R_ = [];

% define variables to test
min_mag_thresh = 4;
max_repose_thresh = 150; % days since last explosion (effectively defines 'intra-eruptive')
bw = 14;

for l = 1:height(TESTLOG)
    
    clearvars -except TESTLOG LOG c s l v v_desc pEFISt OLOG spax vdict P_ R_ min_mag_thresh max_repose_thresh bw
       
    %%% Get the volcano name for TESTLOG and use the features in vdict for
    %%% the matching volcano
    vname = TESTLOG.volcano_name{l}
    v_idx = find(strcmpi(vdict.vname,vname));
    
    % Get eruption table and catalog for this volcano given the magnitude
    % threshold
    ET = obj2table(TESTLOG.DATA(l).E);
    CAT = TESTLOG.DATA(l).CAT;
    CAT(CAT.Magnitude < min_mag_thresh, :) = [];
    
    % Get earthquake times and eruption start stops
    EQT = CAT.DateTime; % n-by-1 vector
    ESS = datenum(mergeintervals([ET.start ET.stop])); % n-by-2 vector
    
    %%%
    % Matrix operations to get repose time and precursor time for each
    % earthquake relative to last and next eruption respectively
    %{
    a, b, and c are m-by-n matrices where
        m is the number of eruptions
        n is the number of earthquakes
    
    a is a matrix of repeated row vectors of earthquake times
    b is a matrix of repeated column vectors of eruption stops
    c is a matrix of repeated column vectors of eruption starts
    %}
    
    EQTm = repmat(EQT', size(ESS,1), 1); % (a)
    STPm = repmat(ESS(:,2), 1, numel(EQT)); % (b)
    STTm = repmat(ESS(:,1), 1, numel(EQT)); % (c)
    
    % repose times (inf if no prev. eruption)
    R = EQTm - STPm; % result is m-by-n matrix
    R(R < 0) = inf; % result is m-by-n matrix
    R = min(R, [], 1) % result is 1-by-n vector
    
    % precursor times (nan if no subsequent eruption)
    P = STTm - EQTm; % m-by-n
    P(P < 0) = NaN; % m-by-n
    P = min(P, [], 1) % 1-by-n
    
    % Master list for all volcanoes
    P_ = [P_ P];
    R_ = [R_ R];
    
    % Remove earthquakes that occurred n days after the last
    % eruption/explosion
%     P_(R_ > max_repose_thresh)= [];
%     R_(R_ > max_repose_thresh) = [];
    
    whos EQTm STPm STTm R P 

%     figure
%     plot(TESTLOG.DATA(l).E); hold on
%     plot(datetime2(CAT.DateTime), CAT.Magnitude, 'ok');
%     xlabel('Time')
%     ylabel('Magnitude')

end

ax(1) = subplot(2,1,1);
H(1) = histogram(P_, 'BinWidth', bw, ...
    'Normalization', 'cdf');
axis square
ylabel('Cumulative Probability (%)')
perc = H(1).Values(1)/numel(P_)*100;
str = [num2str(H(1).Values(1)) ' of ' num2str(numel(P_))];
% title({['Intra-eruptive M' num2str(min_mag_thresh) '+ Earthquakes (AK + Cont. US)']; ...
%     [str ' (' num2str(perc, '%2.1f') '%) occur w/in 14 days' ]; 'of next eruption'})
title(['Intra-eruptive M' num2str(min_mag_thresh) '+ Earthquakes (AK + Cont. US)'])
xlabel('Time to Next Eruption (days)')

%% Add in Hawaii based on Chronologies and global8 catalog

% volcanoes
volc(1).name = 'Kilauea';
volc(1).lat = 19.421;
volc(1).lon = -155.287;

volc(2).name = 'Mauna Loa';
volc(2).lat = 19.475;
volc(2).lon = -155.608;

% load chronologies -- Passarelli & Brodsky
% load('~/Dropbox/JAY-DATA/HawaiiChron_PassarelliBrodsky.mat'); % loads table variable 'chron'

% load chronologies -- Passarelli & Brodsky and Orr et al.
chron = readtable('~/Dropbox/JAY-DATA/HawaiiChron_varsources.xlsx');

P_ = [];
R_ = [];


for n = 1:numel(volc)
    
    % load catalogs
    file = dir(fullfile('~/Dropbox/global8/UnitedStates', strrep(volc(n).name, ' ', ''), 'ANSS_*.mat'));
    if ~isempty(file)
        catalog = global8cat(fullfile(file.folder, file.name));
    else
        break
    end
    
    % radial filter & magnitude filter
    radial_d = distance(volc(n).lat, volc(n).lon, catalog.Latitude, catalog.Longitude);
    radial_d = deg2km(radial_d);
    catalog(radial_d > 30, :) = [];
    catalog(catalog.Magnitude < min_mag_thresh, :) = [];
    
    % extract volcano-specific chronology
    chron2 = chron(strcmpi(chron.Volcano, volc(n).name), :);
    
    EQT = datenum(catalog.DateTime);
    ESS = [[chron2.repose_start(1); chron2.eruption_start] [chron2.repose_start; chron2.eruption_start(end)]]; % turns repose_start & eruption_start into eruption_start & eruption_stop
    ESS = datenum(ESS);
    
        %%%
    % Matrix operations to get repose time and precursor time for each
    % earthquake relative to last and next eruption respectively
    %{
    a, b, and c are m-by-n matrices where
        m is the number of eruptions
        n is the number of earthquakes
    
    a is a matrix of repeated row vectors of earthquake times
    b is a matrix of repeated column vectors of eruption stops
    c is a matrix of repeated column vectors of eruption starts
    %}
    
    EQTm = repmat(EQT', size(ESS,1), 1); % (a)
    STPm = repmat(ESS(:,2), 1, numel(EQT)); % (b)
    STTm = repmat(ESS(:,1), 1, numel(EQT)); % (c)
    
    % repose times (inf if no prev. eruption)
    R = EQTm - STPm; % result is m-by-n matrix
    R(R < 0) = inf; % result is m-by-n matrix
    R = min(R, [], 1) % result is 1-by-n vector
    
    % precursor times (nan if no subsequent eruption)
    P = STTm - EQTm; % m-by-n
    P(P < 0) = NaN; % m-by-n
    P = min(P, [], 1) % 1-by-n
    
    % Master list for all volcanoes
    P_ = [P_ P];
    R_ = [R_ R];
    
    % Limit to intra-eruptive earthquakes
%     P_(R_ > max_repose_thresh)= [];
%     R_(R_ > max_repose_thresh) = [];
    
end

ax(2) = subplot(2,1,2);
H(2) = histogram(P_, 'BinWidth', bw, ...
    'Normalization', 'cdf');
axis square
ylabel('Cumulative Probability (%)')
perc = H(2).Values(1)/numel(P_)*100;
str = [num2str(H(2).Values(1)) ' of ' num2str(numel(P_))];
% title({['Intra-eruptive M' num2str(min_mag_thresh) '+ Earthquakes (Hawaii)']; ...
%     [str ' (' num2str(perc, '%2.1f') '%) occur w/in 14 days' ]; 'of next eruption'})
title(['Intra-eruptive M' num2str(min_mag_thresh) '+ Earthquakes (Hawaii)'])
xlabel('Time to Next Eruption (days)')

%% Beautify Plots

f = gcf;
ax(1).FontSize = 15;
ax(2).FontSize = 15;
linkaxes(ax, 'x')
ax(1).XLim = [0 90];
ax(1).XTick = [0:14:max_repose_thresh];
ax(2).XTick = [0:14:max_repose_thresh];

yticks = 0:0.25:1;
ax(1).YLim = [0 1];
ax(1).YTick = yticks;
ax(1).YTickLabels = yticks*100;

yticks = 0:0.25:1;
ax(2).YLim = [0 1];
ax(2).YTick = yticks;
ax(2).YTickLabels = yticks*100;
