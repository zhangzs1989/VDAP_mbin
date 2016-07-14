function handles = swarmPlot_AGU1A(vname, vlat, vlon, DateTime, lat, lon, Depth, Magnitude, maxz, eruption_windows, baddata, beta_output, t1, t2)
disp(mfilename('fullpath'))
% SWARMPLOT Plots describing the "swarminess" of eq clusters (according to
% Randy White).
% DEPENDENCIES: MATLAB MAPPING TOOLBOX, MAKESTAIR

% UPDATES:
%{
Oct 26, 2015: incorporates 'makeStair' in order to be used with 'datetime'
variable type.
Sa Dec 5, 2015: Removing all graphical visualisations of new maximum
magnitude and running maximum magnitude on the top plot. This may go back
in at some point, but we don't want it for AGU.
Sa Dec 5, 2014: Limits xlim set to t1 and t2. t1 and t2 are inputs.


%}

%% Prep

    % define UTM Zone for volcano
utm_zone = utmzone(vlat,vlon);
m = defaultm('utm');
m.zone = utm_zone;
m = defaultm(m);

    % project earthquake and volcano locations
[vx, vy] = mfwdtran(m, vlat, vlon);
[x, y] = mfwdtran(m, lat, lon);

    % horiz distance to summit
hdist = sqrt( (x-vx).^2 + (y-vy).^2 );
hdist_km = hdist/1000; % change to km

date_time = datetime(datestr(DateTime)); % change to datetime variable type

[cum_mag, cum_moment] = cumMag(Magnitude);  % calculate cumulative magnitude

    % vector of current maximum magnitudes
maxmags = runningMax(Magnitude);
maxmag = max(maxmags);

maxfac = 1.25;
I = Magnitude >= (maxmag-maxfac) ;
totBig = sum(I)-1;

    %fraction of day for count binning
dfrac = 1;
date1 = floor(DateTime(1)); % grabs the date of the first entry
date2 = floor(DateTime(end)); % grabs the date of the last entry

    % event histogram
date_range = date1:dfrac:date2; 
events_per_dfrac = hist((DateTime), date_range); % nbins equals the number of days in the time series; NOTE: must do histogram of dates, not anything else
cepr= cumsum(events_per_dfrac);

%% prepare data to make stair plot

[stair.DateTime, stair.cum_mag] = makeStairs(DateTime, cum_mag);
[stair.date_range, stair.events_per_dfrac] = makeStairs(date_range, events_per_dfrac);

stair.date_time = datetime(datestr(stair.DateTime));

%%
scrsz = get(groot,'ScreenSize');
fh = figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);

%% Magnitudes


sp1 = [];
sp1.ph = subplot(2,1,1); hold on

% [sp1.axh, sp1.hline1, sp1.hline2] = plotyy(DateTime, Magnitude',...
%     date_range, events_per_dfrac,'stairs','stairs'); % Matlab stairs
%     function
[sp1.axh, sp1.hline1, sp1.hline2] = plotyy(date_time, Magnitude',...
    datetime(datestr(stair.date_range)), stair.events_per_dfrac); % JW's stair function


    % Markers for the first plotted item in the first set of plotyy data
% sp1.hline1(1).Color = 'r';

        % Markers for the second plotted item in the first set of plotyy
        % data
        % NOTE: If you add in the new maximum magnitude and the cumulative
        % magnitude stuff, you'll need to change the enumeration value back
        % to 2 (i.e., sp1.hline1(2).LineStyle = 'none';)
sp1.hline1(1).LineStyle = 'none';
sp1.hline1(1).Marker = 'o';
sp1.hline1(1).Color = 'k';
sp1.hline1(1).MarkerFaceColor = 'k';
sp1.hline1(1).MarkerSize = 4;

    % Markers for the third plotted item in the first set of plotyy data
% sp1.hline1(3).LineStyle = 'none';
% sp1.hline1(3).Marker = 'o';
% sp1.hline1(3).Color = 'r';

    % Markers for the first plotted item in the second set of plotyy data
sp1.hline2.LineWidth = 2;
sp1.hline2.Color = 'b';

    % axes settings for left/first(1) and right/second(2) axes
sp1.axh(1).YColor = 'k';
sp1.axh(2).YColor = 'k';

    % Labels
ylabel(sp1.axh(1),'Magnitude','FontWeight','bold','FontSize',12);
ylabel(sp1.axh(2),'Events Per Day','FontWeight','bold','FontSize',12);

    % Remove XTick because ...
% sp1.axh(1).XTick = [];
% sp1.axh(2).XTick = [];

    % Eruption-based Information
min_val = min(min((sp1.axh(:).YLim)));
max_val = max(max((sp1.axh(:).YLim)));
for n = 1:size(eruption_windows,1)
    
        % add rectangle for eruption window
    duration = eruption_windows(n,2) - eruption_windows(n,1);
    eruption = rectangle('Position',[eruption_windows(n,1) min_val duration max_val+1],'FaceColor','r'); hold on;
   
        % add line x-months before eruption (this corresponds to amount of
        % time shown on the map)
    map_start = eruption_windows(n,1)-4*30; % 4 months is the amount of time chosen right now
    map_start_line = plot([map_start map_start],[min_val max_val+1], 'LineStyle',':', 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);
    
end  

uistack(eruption,'bottom'); % ensure that the eruption windows are plotted below everything else


zoom('xon');

% NOTE: How can we tell it if it's ANSS or Jiggle?
title({[vname]})


%% Beta Plots

sp6 = [];
sp6.axh = subplot(2,1,2);
sp6.hline = betaPlot5(vname, beta_output, eruption_windows, baddata);
sp6.axh.XTick = [];
title('') % remove the betaplot title from this axis bc it crowds swarm plot



%% Plot wrap up

linkaxes([sp1.axh sp6.axh],'x');
handles = [fh sp1.axh sp6.axh];


%% Set X & Y Limits

sp6.axh.XLim = [t1 t2];
