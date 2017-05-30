%% 

load('eruptions_dataset') % load example datasets from Pavlof and Redoubt

%% Example 1

% Plot all eruptions from Pavlof volcano
figure
plot(pavlof_dataset);
title('Eruptions at Pavlof Volcano, Alaska')

% add an explosion
t = datetime(2014,06,03);
EXP = EXPLOSION; EXP.start = t; EXP.stop = t; EXP.vei = 1;
plot(EXP)

% add another explosion
t = datetime(1996, 11, 03);
EXP = EXPLOSION; EXP.start = t; EXP.stop = t; EXP.vei = 3;
plot(EXP)


% add axes for repose time and time to next eruption - both additional axes
% are located on the bottom ('bb')
% addXAxes(pavlof_dataset, ax, {'repose', 'precursor'}, 'bb')

%% Example 2

figure

% add an explosion
t = datetime(1990, 01, 07);
EXP = EXPLOSION; EXP.start = t; EXP.stop = t; EXP.vei = 3;
plot(EXP)

% Plot all eruptions from Redoubt volcano
ax = plot(redoubt_dataset);
title('Eruptions at Redoubt Volcano, Alaska')

% add axes for repose time and time to next eruption - both additional axes
% are located on the bottom ('bb')
% addXAxes(redoubt_dataset, ax, {'repose', 'precursor'}, 'bb')
