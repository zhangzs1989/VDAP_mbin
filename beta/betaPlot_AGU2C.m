function o = betaPlot_AGU2C( volcname, beta_output, eruption_windows, bad_data_days, datetime_num, magnitude )

% Get input arguments
% volcname = vname;
% beta_output = beta_output;
% eruption_windows = eruption_windows;
% bad_data_days = baddata;
% datetime_num = DateTime;
datetime_dt = datetime(datestr(datetime_num)); % still need this line
% magnitude = Magnitude;

o = []; % this is just to initialize an output; not sure what output should be right now

%% Figure Set Up
% NOTE:
%{
Instead of using the plotyy command to overlay multiple plots, I will
manually create multiple axes and put them in the same location. Then I
will change properties of each axis (e.g., transparency and the location of
the y tick marks and labels) so that they look nice together. This is, in
fact, what plotyy does automatically. By doing it manually, it is easier to
make the result as I intend it. Manually making individual axes also allows
me to use alternative plotting commands (such as 'stair') with greater
ease.
%}

    % Define the figure and the axes
f = figure;
ax_windows = axes('Tag', 'Windows'); % eruption windows and background windows will be plotted in this axis
ax_mag = axes('Position', ax_windows.Position); % magnitude will be plotted in this axis
ax_beta = axes('Position', ax_windows.Position); % beta information will be plotted in this axis

    % set default color order for plots in the beta window
set(ax_beta, 'ColorOrder', [1 0 0; 0 0 1; 0.38 0.85 0.38], 'NextPlot', 'replacechildren'); % the third color here is a darker green

%% Plot Magnitude Data

    % plot magnitudes
plot(ax_mag, datetime_dt, magnitude, 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 2);

%% Plot beta information

    % concatenate beta value and time data for vectorized plotting
t_checks_all = vertcat(beta_output(1:end).t_checks);
bc_all = vertcat(beta_output(1:end).bc);

    % beta values - this could be further vectorized (one line instead of three)
stairs(ax_beta, t_checks_all(:,1), bc_all(:,1), 'LineWidth', 2, 'Color', 'g'); hold on
stairs(ax_beta, t_checks_all(:,2), bc_all(:,2), 'LineWidth', 2, 'Color', 'b');
stairs(ax_beta, t_checks_all(:,3), bc_all(:,3), 'LineWidth', 2, 'Color', 'r');

    % theoretical beta line
theo_beta_line = plot(ax_beta, [beta_output(1:end).start; beta_output(1:end).stop], repmat([2.57; 2.57],[1 size(beta_output,2)]), 'k--', 'LineWidth', 2); hold on

    % empirical beta lines
starts = sort(repmat([beta_output(1:end).start],[1 3]));
stops = sort(repmat([beta_output(1:end).stop],[1 3]));
emp_beta_line = plot(ax_beta, [starts; stops], repmat(beta_output(1).Be,[2 size(beta_output,2)]), 'LineWidth', 2, 'LineStyle', '--');
% Notes on drawing theo_beta_line:
%{
It took me a long time to figure out how to do this. The matrix of start
times needs to look like this:
    x1start x2start ... xNstart
    x1stop  x2stop  ... xNstop
Use repmat to make the matrix of theoretical beta values be the same size.
%}
% Notes on drawing emp_beta_line:
%{

%}

%% Plot eruption and bad data windows

    % eruption windows & no data windows
axes(ax_windows);
patch([eruption_windows(:,1) eruption_windows(:,2) eruption_windows(:,2) eruption_windows(:,1)]', repmat([0 0 1 1], [size(eruption_windows,1) 1])', 'r', 'FaceAlpha', 0.5); hold on; % see notes below

    % plot line m months before eruption - used to show time highlighted on the map
map_window_start = [eruption_windows(eruption_windows(:,1)>0,1)-4*28 eruption_windows(eruption_windows(:,1)>0,1)-4*28]';
y = repmat([0 1], [size(map_window_start, 1) 1])';
plot(map_window_start,y,'k--','LineWidth',2)

if ~isempty(bad_data_days)
    starts_stops = series2period( [], bad_data_days, 1, 'include'); % start/stop pairs of bad data times as n-by-2 vector
    patch([starts_stops(:,1) starts_stops(:,2) starts_stops(:,2) starts_stops(:,1)]', repmat([0 0 1 1], [size(starts_stops,1) 1])', 'k', 'FaceAlpha', 0.5); hold on;
end

% NOTES:
% Notes on how to create y variables for patch command
%{
repmat([0 0 1 1], [n 1])
-> creates a the row vector [0 0 1 1] and then repeats it for n rows
-> the [0 0 1 1] part effectively creates a rectangle with vertices at
(x1,0), (x2,0), (x2,1), and (x1,1); the values of x1 and x2 are the x data
you supplied to 'patch'

repmat([0 0 1 1], [size(eruption_windows,1) 1])
-> now n is the number of eruption windows
-> now you have a rectangle (with the vertices described above) for each
set of x data that you passed to 'patch'

repmat([0 0 1 1], [size(eruption_windows,1) 1])'
-> transposes the matrix so each set of y values is along the column
direction instead of the row direction (this is how the path command works)
%}
% Note: Patch command can do the same thing as rectangle but has the
% additional feature of allowing you to make the face color transparent


%% Axes Properties

    % Change properties for beta axis
ax_beta.YAxisLocation = 'left';
ax_beta.YLabel.String = 'Beta';
ax_beta.YLabel.FontWeight = 'bold';
ax_beta.XTick = [];
ax_beta.Color = 'none';
% set(ax_beta, 'FontWeight', 'bold');
ax_beta.FontWeight = 'bold';
ax_beta.Box = 'off';

    % Change properties for magnitude axis
ax_mag.YAxisLocation = 'right';
% ax_mag.Color =  'none';
ax_mag.Tag =  'Data';
ax_mag.YLabel.String = 'Magnitude';
ax_mag.YLabel.FontWeight = 'bold';
ax_mag.XLabel.String = 'Date';
ax_mag.XLabel.FontWeight = 'bold';
ax_mag.FontWeight = 'bold';
ax_mag.Box = 'off'; % prevents tick marks from being on other side

    % Change properties for eruption/no-data axis
ax_windows.Color = 'none';
ax_windows.HitTest = 'off'; % prevents windows axis from panning up and down (may be another way to do this)
ax_windows.YTick = [];
ax_windows.XTick = [];
ax_windows.Box = 'on';

%% Figure Properties

title(volcname)
zoom(f,'xon')
linkaxes([ax_windows ax_mag ax_beta],'x');


