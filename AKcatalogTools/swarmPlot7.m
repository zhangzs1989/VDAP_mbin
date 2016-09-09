function A = swarmPlot7(catalog,vinfo,params,beta_output,eruption_windows,baddata,inputFiles)

EventTimes = readtext(inputFiles.EventTimes);
ievents = find(strcmp(EventTimes(2:end,3),vinfo.name));
ievents = ievents+1;

alert_level = convertEventTimes2AlertLevel3(EventTimes(ievents, :));


%%


%% 5. Determine Cumulative Moment & Cumulative Magnitude & bvalue
% get event times from the catalog - returned in Matlab date format
DateTime = datenum(extractfield(catalog, 'DateTime'));

% Calculate cumulative magnitudes and cumulative moments
try
    Magnitude = extractfield(catalog, 'Magnitude');
catch % for jiggle
    Magnitude(1:length(DateTime)) = ones;
end
% Magnitude(isnan(Magnitude))=0;
im = Magnitude==0;
Magnitude(im) = 0.0001;

% Moment = magnitude2moment(Magnitude); % convert each magnitude to a moment
% Imo= ~isnan(Moment);
% CumMoment = cumsum(Moment(Imo)); % calculate cumulative moment
% CumMagnitude = magnitude2moment(CumMoment,'reverse'); % convert cumulative moment back to cumulative magnitude

[cum_mag, cum_moment] = cumMag(Magnitude);  % Calculate cumulative Magnitude

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
% date_time = datetime(datestr(DateTime)); % change to datetime variable type

%%
scrsz = get(groot,'ScreenSize');
fh = figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2],'visible',params.visible);
% fh = figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);

% plot 1
date_range = date1:dfrac:date2;
events_per_dfrac = hist((DateTime), date_range); % nbins equals the number of days in the time series; NOTE: must do histogram of dates, not anything else
% cepr= cumsum(events_per_dfrac);

%% prepare data to make stair plot

[stair.DateTime, stair.cum_mag] = makeStairs(DateTime, cum_mag);
[stair.date_range, stair.events_per_dfrac] = makeStairs(date_range, events_per_dfrac);

stair.date_time = datetime(datestr(stair.DateTime));


sp1 = [];
sp1.ph = subplot(9,1,1:3);hold on
% [sp1.axh, sp1.hline1, sp1.hline2] = plotyy([stair.date_time, date_time, date_time], [stair.cum_mag', Magnitude', maxmags'],...
%                                 datetime(datestr(stair.date_range)), stair.events_per_dfrac);

[sp1.axh, sp1.hline1, sp1.hline2] = plotyy(DateTime, Magnitude',date_range, events_per_dfrac,'plot','stairs');

sp1.hline1.Marker = '.';
sp1.hline1.LineStyle = 'none';
sp1.hline1.Color = 'k';
sp1.hline2.LineWidth = 2;
sp1.hline2.Color = 'b';

sp1.axh(1).YColor = 'k';
sp1.axh(2).YColor = 'k';

ylabel(sp1.axh(1),'Magnitude','FontWeight','bold','FontSize',12);
ylabel(sp1.axh(2),'Events Per Day','FontWeight','bold','FontSize',12,'Color','b');

sp1.axh(1).XTick = [];
sp1.axh(2).XTick = [];


% try to do some smart text positioning
% didn't work well for me
%ypositions = smartYTextPosition( dataset_length, max_height, increment)
% yax=[min(Magnitude) ceil(max(Magnitude))];
yax=[sp1.axh(1).YLim(1) sp1.axh(1).YLim(2)];
% ylim(sp1.axh(1),yax);
% ytextpos = yax(1)+1:yax(2)/length(ievents)-2:yax(2)-1;
ytextpos = yax(2):-(yax(2)-yax(1))/length(ievents):yax(1);

% this needs work (JP)
% for i=1:length(ievents)
%     tA = datevec(EventTimes(ievents(i),1));
%     tB = datevec(EventTimes(ievents(i),2));
%     if datenum(tA)==datenum(tB) %plot a line
%         plot(sp1.axh(1),[datetime(tA) datetime(tA)],yax,'k--')
%     else % plot a box
%         plot(sp1.axh(1),[datetime(tA) datetime(tA) datetime(tB) datetime(tB)],[yax yax(2) yax(1)],'k')
% %         fill([datenum(tA) datenum(tA) datenum(tB) datenum(tB)],[yax yax(2) yax(1)],'b')
%     end
%     text(datenum(tA),ytextpos(i),EventTimes(ievents(i),4),'FontSize',12,'Color','k','BackgroundColor','w','EdgeColor','k');
% end

% title({['Max Mag: ' num2str(maxmag) ' | Cumulative Mag: ' num2str(max(cum_mag)) ],...
%     [int2str(totBig),' events within ',num2str(maxfac), ' mag units of max mag']})
%title({[vinfo.name,': ',catTitle],[datestr(t1,'mm/dd/yyyy') ' to ' datestr(t2,'mm/dd/yyyy')]})

% Eruption-based Information
min_val = min(min((sp1.axh(:).YLim)));
max_val = max(max((sp1.axh(:).YLim)));
for n = 1:size(eruption_windows,1)
    
        % add rectangle for eruption window
    duration = eruption_windows(n,2) - eruption_windows(n,1);
    eruption = rectangle('Position',[eruption_windows(n,1) min_val duration max_val+1],'FaceColor','r'); hold on;
   
        % add line x-months before eruption (this corresponds to amount of
        % time shown on the map)
    map_start = eruption_windows(n,1)-params.AnomSearchWindow; % 4 months is the amount of time chosen right now
    map_start_line = plot([map_start map_start],[min_val max_val+1], 'LineStyle',':', 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);
    
end  

try
    uistack(eruption,'bottom'); % ensure that the eruption windows are plotted below everything else
end

zoom('xon');
% plotAlertLevel(ap1.axh(1), alert_level)

%%

%% Horizontal Distance vs. Time
I = ~isnan(maxmags);
% Get lat & long of events
try
    lat = extractfield(catalog, 'Latitude');
    lon = extractfield(catalog, 'Longitude');
    Depth = extractfield(catalog, 'Depth');
catch % for jiggle
    lat(1:length(DateTime)) = vinfo.lat;
    lon(1:length(DateTime)) = vinfo.lon;
    Depth(1:length(DateTime)) = zeros;
end
date_time = datetime(datestr(DateTime)); % change to datetime variable type
%%

utm_zone = utmzone(vinfo.lat,vinfo.lon);
m = defaultm('utm');
m.zone = utm_zone;
m = defaultm(m);
[vx, vy] = mfwdtran(m, vinfo.lat, vinfo.lon);
[x, y] = mfwdtran(m, lat, lon);

% horiz distance to summit
hdist = sqrt( (x-vx).^2 + (y-vy).^2 );
hdist_km = hdist/1000;

sp4 = [];
sp4.axh = subplot(9,1,4); hold on

tmp=DateTime(I);
II(1:length(tmp))=zeros;
for i=1:length(tmp)
    kk = find(tmp(i) == DateTime);
    II(i) = kk(1);
end

II=[];
sp4.hline = plot(date_time,hdist_km,'k.',date_time(II),hdist_km(II),'ro');
% xlim([date1 date2]);
% set(gca,'YTick',[0 50])
% set(gca,'YTickLabel',{'0'; '50'})
ylabel({'Horiz';'Distance';'to Summit'},'FontWeight','bold','FontSize',12)

% yax=[0 ceil(max(hdist_km))];
% ylim(yax);
% % ytextpos = yax(1)+1:yax(2)/length(ievents)-2:yax(2)-1;
% ytextpos = yax(2)-1:-yax(2)/length(ievents)-2:yax(1)+1;
%
% for i=1:length(ievents)
%     tA = datevec(timeLineLocs(ievents(i),1));
%     plot([datetime(tA) datetime(tA)],yax,'b--')
%     text(datenum(tA),ytextpos(i),timeLineLocs(ievents(i),4),'FontSize',12,'Color','b');
% end

%% Depth vs. Time

sp5 = [];
sp5.axh = subplot(9,1,5);
sp5.hline = plot(date_time,-Depth,'k.',date_time(II),-Depth(II),'ro');
% xlim([date1 date2]);
ylabel('EQ Depth','FontWeight','bold','FontSize',12)
ylim([params.max_depth_threshold*-1 -4*-1])

%%

sp6 = [];
sp6.axh = subplot(9,1,6:7); hold on
sp6.hline = betaPlot5(vinfo.name, beta_output,  eruption_windows, baddata, params, inputFiles);
datetick(sp6.axh,'keeplimits')
% sp6.hline = betaPlot2_JJW5(vname, beta_output);

% legend(legendinfo,'Location','Best')

% sp6 = [];
% sp6.axh = subplot(7,1,6:7); hold on
% sp6.hline = betaPlot_AGU2C(vinfo.name, beta_output, eruption_windows, baddata, datenum(DateTime), Magnitude);
% datetick(sp6.axh,'keeplimits')
% % sp6.hline = betaPlot2_JJW5(vname, beta_output);
% 
% % legend(legendinfo,'Location','Best')

%% Cumulative Magnitude/Moment by Bin

type = params.binMagVbinMom; % options are 'mag' for magnitude or 'mom' for moment

sp8 = [];
sp8.axh = subplot(9,1,8:9); hold on
for n = 1:numel(beta_output)
    
    % Option of converting magnitudes to moments
    %{
    % This isn't pretty; this option should be done somewhere else whenever
    % .bin_mag is actually computed. Ideally, beta_output should be made a
    % class, and .bin_mag and .bin_mom should be automatically updated
    % depending on the other.
    %}
    if strcmp(type, 'mom')
        
        for nn=1:numel(beta_output.bin_sizes)
            beta_output(n).bin_mag(:,nn) = magnitude2moment(beta_output(n).bin_mag(:,nn));
        end
        
    end

    % ISSUE: below assumes no more than 3 window sizes allowed
    sp8.hline(1) = stairs(beta_output(n).t_checks(:,1), beta_output(n).bin_mag(:,1), 'g');
    try
        sp8.hline(2) = stairs(beta_output(n).t_checks(:,2), beta_output(n).bin_mag(:,2), 'b');
    end
    try
        sp8.hline(3) = stairs(beta_output(n).t_checks(:,3), beta_output(n).bin_mag(:,3), 'r');
    end
end
datetick(sp8.axh, 'keeplimits');
if strcmp(type, 'mag')
    ylabel('Cumulative Magnitude')
else
    ylabel('Cumulative Moment')
end

%%
linkaxes([sp1.axh sp4.axh sp5.axh sp6.axh sp8.axh],'x');
% xl = extractfield(beta_output,'start');
% xlim([min(xl) max(xl)]);
% xlim([t1 t2]);
% axis 'auto y'
% zoom('xon');

A = [fh sp1.axh sp4.axh sp5.axh sp6.axh];
