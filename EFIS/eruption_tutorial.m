%% 

load('eruptions_dataset') % load example datasets from Pavlof and Redoubt

%% Example 1

% Plot all eruptions from Pavlof volcano
figure
ax = plotEruption(pavlof_dataset);
title('Eruptions at Pavlof Volcano, Alaska')

% add axes for repose time and time to next eruption - both additional axes
% are located on the bottom ('bb')
addXAxes(pavlof_dataset, ax, {'repose', 'precursor'}, 'bb')

%% Example 2

% Plot all eruptions from Redoubt volcano
figure
ax = plotEruption(redoubt_dataset);
title('Eruptions at Redoubt Volcano, Alaska')

% add axes for repose time and time to next eruption - both additional axes
% are located on the bottom ('bb')
addXAxes(redoubt_dataset, ax, {'repose', 'precursor'}, 'bb')
