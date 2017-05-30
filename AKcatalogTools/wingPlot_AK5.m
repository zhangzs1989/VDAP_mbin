function H = wingPlot_AK5(vinfo, t1, t2, catalog, mapdata, params)

disp(mfilename('fullpath'))
% WINGPLOT Plots data in map view along with cross section profiles.
%{
2015 Oct 22 - Cleveland has an error when I try to plot the other stations.
Trying to fix that. JJW
Dec 22, 2015 - Change Color and InvertHardcopy properties of the figure
handle which should result in more desireable figure printing.
InvertHardcopy should make the printed png look more like what is on the
screen.

%}

%% Data Prep

% Extract all necessary data from the catalog
if size(catalog,2) > 0
    Lat = extractfield(catalog, 'Latitude');
    Lon = extractfield(catalog, 'Longitude');
    Depth = extractfield(catalog, 'Depth');
    DateTime = datenum(extractfield(catalog, 'DateTime'));
    Magnitude = extractfield(catalog, 'Magnitude');
    Moment = magnitude2moment(Magnitude); % convert each magnitude to a moment
    eq_plot_size = rescaleMoments(Moment,[5 100]); % base event marker size on moment (a way to make a log plot)
else
    Lat = [];
    Lon = [];
    Depth = [];
    DateTime =[];
    Magnitude = [];
    eq_plot_size = [];
end

% t1 = min(DateTime);
% t2 = max(DateTime);

max_depth = -(abs(params.max_depth_threshold)); % ensure that the value is negative

%% Figure Prep
longannO = mapdata.outer(:,2); latannO=mapdata.outer(:,1);
if ~isnan(mapdata.inner)
    longannI = mapdata.inner(:,2); latannI=mapdata.inner(:,1);
end
%map axes

% % [latlim, lonlim] = bufgeoquad(latlim, lonlim, .005, .005);
if params.topo
    lonlim = mapdata.RA.LongitudeLimits;
    latlim = mapdata.RA.LatitudeLimits;
%     latlim = [min([Lat'; latannO]) max([Lat'; latannO])];
%     lonlim = [min([Lon'; longannO]) max([Lon'; longannO])];
    ZA = mapdata.ZA;
    RA = mapdata.RA;
    crange = 200:200:max(max(ZA));
else
    latlim = [min([latannO]) max([latannO])];
    lonlim = [min([longannO]) max([longannO])];
    crange =[];
    % deal with crossing 180 longitude for semisepochnoi
    if sign(min(longannO)) ~= sign(max(longannO))
        longannO(longannO<0) = longannO(longannO<0) + 360;
        lonlim = [min([Lon'; longannO]) max([Lon'; longannO])];
    end
end

%[latlim, lonlim] = bufgeoquad(latlim, lonlim, .005, .005);
%% Figure

scrsz = get(groot,'ScreenSize');
% H = figure('Position',[1 1 scrsz(3)/2 scrsz(3)/2]);
H = figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(3)/2],'visible',params.visible);
H.Color = [1 1 1]; % sets the background of the figure panel to white
H.InvertHardcopy = 'off'; % should make the printed figure look more like what is on the screen

%% Subplots

subplot(3,3,[1 2 4 5]);
ax = usamap(latlim, lonlim);
if params.coasts
    geoshow(mapdata.coastlines,'FaceColor', [.75 .75 .75])
end
title({vinfo.name,[datestr(t1,'mm/dd/yyyy') ' to ' datestr(t2,'mm/dd/yyyy')],[int2str(numel(Lat)),' events']})
if params.topo
    contourm(double(ZA),RA,double(crange),'LineColor',[0.5  0.5  0.5]);
else
    disp('No contours to plot')
end
if params.coasts
    colormap('jet')
    freezeColors; % I think this is a non-Matlab function, watch out!
end
% Plot earthquakes and the volcano
colormap('jet')
try scatterm(ax, Lat, Lon, eq_plot_size, DateTime); catch warning('BUG??'); end %JP: came across a weird bug here that I can't explain 
hcb=colorbar;
caxis([t1 t2])
datetickJP(hcb,'y',2); % this is a non-Matlab function, watch out!

try
    plotm(vinfo.vlats, vinfo.vlons,'dk','MarkerFaceColor','w','MarkerSize',6); % plot the volcano; make ared triangle
catch
    disp('no summits available')
    vinfo.vlats = [];
    vinfo.vlons = [];
    vinfo.velevs= [];
end
try
    plotm(latannO, longannO, 'k')
catch
    disp('no annulus plotted')
end
try plotm(latannI, longannI, 'k'); catch, warning('No inner annulus plotted'), end % plot the annulus as a black line
try plotm(mapdata.sta_lat, mapdata.sta_lon,'^k','MarkerFaceColor','k'); catch, warning('No other stations in the area'), end

h = scaleruler('Units','km','RulerStyle','patches');

%% Project Data to Projected (xy) Coordinates

[x,y] = mfwdtran(Lat,Lon); % earthquake events
[vx,vy] = mfwdtran(vinfo.lat,vinfo.lon); % volcano location
[sta_x, sta_y] = mfwdtran(mapdata.sta_lat, mapdata.sta_lon); % station locations
[px, py] = mfwdtran(vinfo.vlats, vinfo.vlons); % location of other summit *p*eaks

% z = Depth;


%% Map & XSection

% params.angle = the angle (degrees) at which you want to rotate the cross section
% if params.angle == 0; params.angle = 0.001; end;
params.angleA = params.angle*pi/180; params.angleB = (params.angle+90)*pi/180; % radian angle for A and B

if numel(params.srad) == 1
    r = params.srad(1)*1000; % radius (meters)
else
    r = params.srad(2)*1000; % radius (meters)
end
% deepest = -max(Depth); % an odd way to get the depth of the deepest quake (negative value)
if exist('ZA','var')
    highest = max(max(double(ZA)))/1000; % highest elevation in km
else
    highest = 3;
end


% Define the location of xsection start and stop - points are relative
% to proj system, not the volcano!
A1.x = vx - r*cos(params.angleA); A1.y = vy - r*cos(params.angleA); % xy coords of A
A2.x = vx + r*cos(params.angleA); A2.y = vy + r*cos(params.angleA); % xy coords of A'

B1.x = vx - r*cos(params.angleB); B1.y = vy + r*cos(params.angleB); % xy coords of B
B2.x = vx + r*cos(params.angleB); B2.y = vy - r*cos(params.angleB); % xy coords of B'

% Define the location of xsection start and stop - points are relative
% to proj system, not the volcano!
A1.x = vx - r*cos(params.angleA); A1.y = vy - r*sin(params.angleA); % xy coords of A
A2.x = vx + r*cos(params.angleA); A2.y = vy + r*sin(params.angleA); % xy coords of A'

B1.x = vx - r*sin(params.angleA); B1.y = vy + r*cos(params.angleA); % xy coords of B
B2.x = vx + r*sin(params.angleA); B2.y = vy - r*cos(params.angleA); % xy coords of B'


% convert xsection start and stop points back to geo coordinates
[A1.lat, A1.lon] = minvtran(A1.x,A1.y); % lat-long coords of A
[A2.lat, A2.lon] = minvtran(A2.x,A2.y); % lat-long coords of A'

[B1.lat, B1.lon] = minvtran(B1.x,B1.y); % lat-long coords of B
[B2.lat, B2.lon] = minvtran(B2.x,B2.y); % lat-long coords of B'

% if coordflag; A1.lon(A1.lon<0) = A1.lon(A1.lon<0)+360; end
% if coordflag; B1.lon(B1.lon<0) = B1.lon(B1.lon<0)+360; end
% if coordflag; A2.lon(A2.lon<0) = A2.lon(A2.lon<0)+360; end
% if coordflag; B2.lon(B2.lon<0) = B2.lon(B2.lon<0)+360; end

% place A-A' line on mapview
plotm(A1.lat,A1.lon, 'sr'); % beginning of A xsection
textm(A1.lat,A1.lon, 'A'); % A xsection label
plotm([A1.lat A2.lat],[A1.lon A2.lon],'r'); % A-A' xsection

% place B-B' on mapview
plotm(B1.lat,B1.lon, 'sb'); % beginning of B xsection
textm(B1.lat,B1.lon, 'B'); % B xsection label
plotm([B1.lat B2.lat],[B1.lon B2.lon]); % B-B' xsection

%% Get locations relative to each xs line

% stub - send info to Command Window
% sprintf('A (degrees): %f',params.angleA/pi*180)
% sprintf('B (degrees): %f',params.angleB/pi*180)

% earthquakes
x0 = x - vx; y0 = y - vy; % adjust eq coordinates relative to volcano
a = sqrt(x0.^2 + y0.^2); % distance from origin (volcano) to point (earthquake)
angle = atan2(y0,x0); % angle from volcano (origin) to eq
phiAA = angle - params.angleA; % angle between xsection vector and vector to point
phiBB = angle - params.angleB;
AA0 = a .* cos(phiAA); % length along cross section A-A' from volcano (origin)
BB0 = -1*(a .* cos(phiBB)); % length along cross section B-B' from volcano (origin)

% stations
sta_x0 = sta_x - vx; sta_y0 = sta_y - vy; % adjust station coordinates
a = sqrt(sta_x0.^2 + sta_y0.^2); % distance from origin (volcano) to point (earthquake)
angle = atan2(sta_y0,sta_x0); % angle from volcano (origin) to eq
phiAA = angle - params.angleA; % angle between xsection vector and vector to point
phiBB = angle - params.angleB;
sta_AA0 = a .* cos(phiAA); % length along cross section A-A' from volcano (origin)
sta_BB0 = -1*(a .* cos(phiBB)); % length along cross section B-B' from volcano (origin)

% other volcanoes
px0 = px - vx; py0 = py - vy; % adjust station coordinates
a = sqrt(px0.^2 + py0.^2); % distance from origin (volcano) to point (earthquake)
angle = atan2(py0,px0); % angle from volcano (origin) to eq
phiAA = angle - params.angleA; % angle between xsection vector and vector to point
phiBB = angle - params.angleB;
pAA0 = a .* cos(phiAA); % length along cross section A-A' from volcano (origin)
pBB0 = -1*(a .* cos(phiBB)); % length along cross section B-B' from volcano (origin)

%%

% get the topograparams.anglec profiles
% double(ZA) -> must turn ZA, the map data, into a double array
% the following descriptions of outputs apply for both A & B lines
% zi <- elevation values along cross section
% ri <- points along the profile correspong to zi; measured in degrees
% away from initial point
% lati <- points of latitude along the profile corresponding to zi
% loni <- points of longitude along the profile corresponding to zi
if exist('ZA','var')
    [ziA, riA, latiA, loniA] = mapprofile(double(ZA), RA, [A1.lat A2.lat], [A1.lon A2.lon], 'meter');
    [ziB, riB, latiB, loniB] = mapprofile(double(ZA), RA, [B1.lat B2.lat], [B1.lon B2.lon], 'meter');
    
    % convert topograparams.anglec profile marks to xy coordinates
    [xiA,yiA] = mfwdtran(latiA,loniA); xiA = xiA - vx; yiA = yiA - vy;
    [xiB,yiB] = mfwdtran(latiB,loniB); xiB = xiB - vx; yiB = yiB - vy;
end

%% Bottom XSection profile

xs_A = subplot(3,3,[7 8]);
if exist('ZA','var')
    hdist = deg2km(riA)/100000; hdist = hdist - mean(hdist); % convert degrees away from profile start to km away from center point
    pb1 = plot(hdist,ziA/1000,'r'); hold on;% elevation (ziA) needs to be converted from m to km
end
try
    pb2 = plot(pAA0/1000,-vinfo.elev,'dk','MarkerFaceColor','w');hold on;
    pb3 = plot(sta_AA0/1000,mapdata.sta_elev,'^k','MarkerFaceColor','k');
end
pb4 = scatter(AA0/1000,-Depth,eq_plot_size,DateTime); % convert AA0 to km
colormap;
caxis([t1 t2])

% axes
xlim([-r/1000 r/1000]); % convert axes limits to km
ylim([max_depth ceil(highest)])
xlabel('Cross-Section A-A'' Dist (km)')
ylabel('Depth (km)')
% title('Cross-Section A-A''')


%% Right XSection profile

xs_B = subplot(3,3,[3 6]);
if exist('ZA','var')
    hdist = deg2km(riB)/100000; hdist = hdist - mean(hdist); % convert degrees away from profile start to km away from center point
    pr1 = plot(ziB/1000,hdist,'b'); hold on;% elevation (ziB) needs to be converted from m to km
end
try
    pb2 = plot(-vinfo.elev,pBB0/1000,'dk','MarkerFaceColor','w');hold on;
    pb3 = plot(mapdata.sta_elev,sta_BB0/1000,'^k','MarkerFaceColor','k');
end
pr2 = scatter(-Depth,BB0/1000,eq_plot_size,DateTime); % convert BB0 to km
colormap;
caxis([t1 t2])

% axes
set(gca,'XDir','reverse');
xlim([max_depth ceil(highest)])
ylim([-r/1000 r/1000]); % convert axes limits to km
xlabel('Depth (km)')
ylabel('B''-B Dist (km)')
xs_B.YAxisLocation = 'right';
xs_B.XAxisLocation = 'top';
xs_B.YDir = 'reverse';
% title('Cross-Section B-B''')

% Lock Depth and Dist axes on B-B' with Depth and Dist axes on A-A'
xs_B.XTick = xs_A.YTick; % Depth
xs_B.XTickLabel = xs_A.YTickLabel;
xs_B.YTick = xs_A.XTick; % Dist
xs_B.YTickLabel = xs_A.XTickLabel;

set([xs_A xs_B],'Color',[0.75 0.75 0.75]); % sets the background color for the xsection to gray so that colors are visible

end