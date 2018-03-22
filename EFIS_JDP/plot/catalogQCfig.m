function F = catalogQCfig(catalog,vinfo,eruptionCat,Mc,varargin)

if nargin == 3
    visibility = 'off';
else
    visibility = varargin{1};
    visibility = validatestring(visibility,{'on','off'}, mfilename, 'visibility');
end
dfac = 30;

if isempty(eruptionCat)
    %     input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
    %     load(input.gvp_eruptions); % spits out volcanoCat
%     warning('No eruption times plotted')
end

if isempty(catalog)
    warning('empty catalog')
    %     F = [];
    %     return
    
    authors = [];
    ua = [];
    dts =[];
    mags = [0 5];
    cata = [];
else
    %% Now do catalog QC and save
    authors = extractfield(catalog,'AUTHOR');
    ua = unique(authors);
    dts = datetime(datevec(extractfield(catalog,'DateTime')));
    mags = extractfield(catalog,'Magnitude');
    lats =extractfield(catalog,'Latitude');
    lons =extractfield(catalog,'Longitude');
    deps =extractfield(catalog,'Depth');
    
    if isfield(catalog,'DEPFIX')
        DFix = extractfield(catalog,'DEPFIX');
    else
        DFix = [];
    end
    
end

for i=1:numel(ua)
    cata(:,i) = strcmp(authors,ua(i));
end
ncata = sum(cata);

authors2=authors;
if numel(ua)>2
    for i=1:numel(ncata)
        if ncata(i) <= 10
            authors2(cata(:,i)) = {'other'};
        end
    end
end
ua = unique(authors2);
clear cata;
for i=1:numel(ua)
    cata(:,i) = strcmp(authors2,ua(i));
end
%%
% scrsz = get(groot,'ScreenSize');
scrsz = [ 1 1 1080 2560];
F = figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/3],'visible',visibility);
set(F,'Renderer','OpenGL'); %supposed to be faster
% create color palette
c = get(gca,'colororder');
ax1 = subplot(4,4,1:4); hold on
%%
if numel(ua)>size(c,1)
    nc = numel(ua)-size(c,1);
    str=sprintf('colormap%s%d%s','(jet(',nc,'))');
    cj = eval(str);
    c = [c;  cj];
end
c2 = [];
yyaxis left
for i=1:numel(ua)
    c2 = [c2; c(i,:)];
    plot(dts(cata(:,i)),mags(cata(:,i)),'.','Color',c(i,:))
end
ax1.YColor = 'k';
ylabel('Mag')
xlabel('Date')
ua2 = ua;
title([vinfo.name,', ',vinfo.country,' (',int2str(numel(dts)),' events)'])
% plot Mc
if ~isempty(Mc)
    if size(Mc,2)==3 % could be two times per Mc (window) or just one from interp
        Mc = Mc(:,2:3); % take window end dates as Mc times
    end
    a=plot(datetime(datevec(Mc(:,1))),Mc(:,2),'k-','LineWidth',2);
    ua2 = [ua2,'Mc'];
end
% plot eruptions
for i=1:numel(eruptionCat)
    if isempty(eruptionCat(i).EndDate)
        eruptionCat(i).EndDate = datestr(datenum(eruptionCat(i).StartDate) + 1);
    end
    plot([datetime(eruptionCat(i).StartDate),datetime(eruptionCat(i).StartDate)],[floor(min(mags)),ceil(max(mags))],'r-','LineWidth',1);
    plot([datetime(eruptionCat(i).EndDate)+1,datetime(eruptionCat(i).EndDate)+1],[floor(min(mags)),ceil(max(mags))],'b-.');

end
if ~isempty(eruptionCat)
    ua2 = [ua2,'Eruption start','Eruption End'];
end
% legend(ua2,'Location','best')
legend(a,ua2(length(ua)+1:length(ua2)),'Location','best')
box on, grid on
%%
yyaxis right
if length(dts)>dfac*2
    h=histogram(datenum(dts),floor(min(datenum(dts))):dfac:ceil(max(datenum(dts))));
    h.FaceColor = 'none';
    ylabel('Event Count')
else
    ax1.YTick = [];
end
ax1.YColor = 'k';
%%
if isempty(catalog)
    datetick('x',12)
    return
end

ax2 = subplot(4,4,5:8); hold on, grid on
for i=1:numel(ua)
    plot(dts(cata(:,i)),deps(cata(:,i)),'.','Color',c(i,:))
end
axis ij
ylabel('Depth');
xlabel('Date')
ylim([0 max(deps)])
box on, grid on

ax3 = subplot(4,4,9:12); hold on, grid on
[ARCLEN, AZ] = distance(lats,lons,vinfo.lat,vinfo.lon);
for i=1:numel(ua)
    plot(dts(cata(:,i)),deg2km(ARCLEN(cata(:,i))),'.','Color',c(i,:))
end
ylabel('Distal Map Distance');
xlabel('Date')
ylim([0 max(deg2km(ARCLEN))])
box on, grid on

% t1min = floor(min(datenum(dts)));
% t1min = datenum(str2num(datestr(t1min,'yyyy')),1,1);
t1min = datenum(1964,1,1); % omit GEM events
%% NEED this twice otherwise axes get screwed up. matlab bug?
try
    xmin = min([datetime(datevec(Mc(:,1)));datetime(datevec(t1min))]);
    xmax = max(datetime(datevec(Mc(:,1)+7)));
catch
    try
        xmin = min([datenum(extractfield(eruptionCat,'StartDate')); datenum(dts)]);
        xmax = max([datenum(extractfield(eruptionCat,'EndDate')); datenum(dts)])   ;
    catch
        xmin = min([datenum(dts)]);
        xmax = max([datenum(dts)]);
        if xmin==xmax
            xmin =xmin -1;
            xmax = xmax + 1;
        end
    end
end
try
    xlim([xmin xmax]);
catch
    xlim([datenum(xmin) datenum(xmax)]) % different versions of matlab datetime issue
end
% try
linkaxes([ax1 ax2 ax3],'x')
% catch
%     xlim(ax1,[dateshift(min(dts),'start','month') dateshift(max(dts),'end','month')])
%     xlim(ax2,[dateshift(min(dts),'start','month') dateshift(max(dts),'end','month')])
%     xlim(ax2,[floor(min(datenum(dts))) ceil(max(datenum(dts)))])
% end
zoom('xon')
try
    xmin = min([datetime(datevec(Mc(:,1)));datetime(datevec(t1min))]);
    xmax = max(datetime(datevec(Mc(:,1)+7)));
catch
    try
        xmin = min([datenum(extractfield(eruptionCat,'StartDate')); datenum(dts)]);
        xmax = max([datenum(extractfield(eruptionCat,'EndDate')); datenum(dts)])   ;
    catch
        xmin = min([datenum(dts)]);
        xmax = max([datenum(dts)]);
        if xmin==xmax
            xmin =xmin -1;
            xmax = xmax + 1;
        end        
    end
end
try
    xlim([xmin xmax]);
catch
    xlim([datenum(xmin) datenum(xmax)]) % different versions of matlab datetime issue
end

%%
subplot(4,4,13)
X=categorical(authors2);
p1=pie(X);
colormap(c2)
title('Authors');
legend(ua,'Location','west')
%%
subplot(4,4,14)
imn = ~isnan(mags);
% ime = ~isempty(mags);
% imb = imn & ime;
X = categorical(imn);
p2=pie(X);
title('Have Magnitudes?');
%%
subplot(4,4,15)
dn = isnan(deps);
if ~isempty(DFix)
    df = cellfun('isempty',DFix);
    dc = df | dn;
else
    dc = dn;
end
X = categorical(dc);
p3=pie(X);
title('Have Good Depths?');
%%
subplot(4,4,16)
% ef = cellfun('isempty',lats);
en = ~isnan(lats);
% ec = ef | en;
X = categorical(en);
p4=pie(X);
title('Have Epicenters?')
%%

end