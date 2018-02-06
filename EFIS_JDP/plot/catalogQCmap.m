function H = catalogQCmap(catalog,vinfo,params,mapdata)

% if nargin == 2
%     visibility = 'off';
%
% elseif nargin == 3
%
%     visibility = varargin{1};
%     visibility = validatestring(visibility,{'on','off'}, mfilename, 'visibility');
% end

% if isempty(catalog)
%     H = [];
%     return
% end
%%
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
% params.coasts = true;
% params.topo = false;
% params.visible = 'on';
if size(catalog,2) > 0 && ~isempty(catalog)
    
    authors = extractfield(catalog,'AUTHOR');
    if isempty(authors)
        warning('No AUTHOR attribute')
    end
    
    ua = unique(authors);
    for i=1:numel(ua)
        cata(:,i) = strcmp(authors,ua(i));
    end
    ncata = sum(cata);
    authors2=authors;
    for i=1:numel(ncata)
        if ncata(i) <= 10
            authors2(cata(:,i)) = {'other'};
        end
    end
    ua = unique(authors2);
    clear cata;
    for i=1:numel(ua)
        cata(:,i) = strcmp(authors2,ua(i));
    end
    
    %%
    Lat = extractfield(catalog, 'Latitude');
    Lon = extractfield(catalog, 'Longitude');
    Depth = extractfield(catalog, 'Depth');
    DateTime = datenum(extractfield(catalog, 'DateTime'));
    Magnitude = extractfield(catalog, 'Magnitude');
    Moment = magnitude2moment(Magnitude); % convert each magnitude to a moment
    eq_plot_size = rescaleMoments(Moment,[5 100],[-1 5]); % base event marker size on moment (a way to make a log plot)
else
    Lat = [];
    Lon = [];
    Depth = [];
    DateTime =[];
    Magnitude = [];
    eq_plot_size = [];
end

% [ARCLEN, AZ] = distance(Lat,Lon,vinfo.lat,vinfo.lon);
% I = ARCLEN ==max(ARCLEN);
% if ~isempty(I)
%     [ outer, inner ] = getAnnulusm( vinfo.lat, vinfo.lon, deg2km(ARCLEN(I)));
% else
    [ outer, inner ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad(2));
% end
if isempty(mapdata)
    mapdata = prep4WingPlot(vinfo,params,input,outer,inner);
end
max_depth = -max(Depth); % ensure that the value is negative

%% Figure Prep
longannO = mapdata.longann;
latannO = mapdata.latann;
%map axes

if params.topo
    try
        ZA = mapdata.ZA;
        RA = mapdata.RA;
        crange = 200:200:max(max(ZA)); %hard coded for now
    catch
        crange = [];
        warning('TOPO NO BUENO')
    end
else
    crange =[];
end
%% Figure

% scrsz = get(groot,'ScreenSize');
scrsz = [ 1 1 1080 1920];
% H = figure('Position',[1 1 scrsz(3)/2 scrsz(3)/2]);
H = figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(3)/2],'visible',params.visible);
H.Color = [1 1 1]; % sets the background of the figure panel to white
H.InvertHardcopy = 'off'; % should make the printed figure look more like what is on the screen

ax = worldmap(mapdata.latlim, mapdata.lonlim);
if isfield(params,'coasts') && params.coasts
    try
        geoshow(mapdata.coastlines,'FaceColor', [.75 .75 .75],'LineStyle','none')
    catch
        warning('problem with coastlines')
    end
end
setm(ax, 'MlabelParallel', 'south');

% title({vinfo.name,[datestr(t1,'mm/dd/yyyy') ' to ' datestr(t2,'mm/dd/yyyy')],[int2str(numel(Lat)),' events, Mmax = ',...
%     num2str(max(Magnitude),'%2.1f')]})
if params.topo
    try
        contourm(double(ZA),RA,double(crange),'LineColor',[0.5  0.5  0.5]);
    catch
        warning('TOPO NO BUENO')
    end
else
    disp('No contours to plot')
end
title([vinfo.name,', ',vinfo.country,' (',int2str(numel(DateTime)),' events)'])
% if params.coasts
%     colormap('jet')
%     freezeColors; % I think this is a noncMatlab function, watch out!
% end
% Plot earthquakes and the volcano
% create color palette
if size(catalog,2) > 0 && ~isempty(catalog)
    
    c = get(gca,'colororder');
    if numel(ua)>size(c,1)
        nc = numel(ua)-size(c,1);
        str=sprintf('colormap%s%d%s','(jet(',nc,'))');
        cj = eval(str);
        c = [c;  cj];
    end
    
    c2 = [];
    % colormap(c(1:numel(ua),:))
    for i=1:numel(ua)
        c2 = [c2; c(i,:)];
        a(i) = plotm(Lat(cata(:,i)),Lon(cata(:,i)),'.','Color',c(i,:));
    end
    l=legend(a,ua,'Location','Best');
end

% scatterm(ax, Lat, Lon, eq_plot_size, DateTime);
% hcb=colorbar;
% caxis([t1 t2])
% datetickJP(hcb,'y',23); % this is a non-Matlab function, watch out!

try
    plotm(vinfo.Latitude, vinfo.Longitude,'dk','MarkerFaceColor','w','MarkerSize',6); % plot the volcano; make ared triangle
catch
    disp('No summit info available')
end
try
    plotm(latannO, longannO, 'k')
catch
    disp('No annulus available')
end

try plotm(latannI, longannI, 'k'); catch, disp('No inner annulus plotted'), end % plot the annulus as a black line
try plotm(mapdata.sta_lat, mapdata.sta_lon,'^k','MarkerFaceColor','k'); catch, disp('No stations in the area'), end

h = scaleruler('Units','km');
setm(h,'MinorTick',[0])
% setm(h,'MajorTick',[0,round(params.srad(2)/4,-1)])



end