function [MasterMc,H] = mkMasterMc2(vinfo,McG,McV,McL,catalog,params)

if isempty(catalog)
    mags = [];
    dtimes = [];
else
    mags = extractfield(catalog,'Magnitude');
    dtimes = datenum(extractfield(catalog,'DateTime'));
end

scrsz = [ 1 1 1080 1920];
timeline = McG.McDaily(1,1):floor(now);
iscMc = interp1(McG.McDaily(:,1),McG.McDaily(:,2),timeline);
gmc = nan(1,length(timeline));
dtimes = datetime(datevec(dtimes));

if size(McV.McDaily,1)<2
    vmc = gmc;
else
    vmc= interp1(McV.McDaily(:,1),McV.McDaily(:,2),timeline);
end

if isempty(McL)
    lmc = gmc;
elseif size(McL.McDaily,1)>=2
    lmc = interp1(McL.McDaily(:,1),McL.McDaily(:,2),timeline);
else
    lmc = gmc;
end

%% compute master Mc
% take the min of the Mcs
% mMc = [iscMc',vmc',lmc'];
% mMc = min(mMc,[],2,'omitnan');
% use all local eqs
vn = ~isnan(vmc);
ln = ~isnan(lmc);
mMc = iscMc';
mMc(vn) = vmc(vn);
mMc(ln) = lmc(ln);

%% extrapolate end value to today
% isn = find(~isnan(mMc));
% if ~isempty(isn)
%     endrange=isn(end):length(mMc);
%     mMc(endrange)=ones(length(endrange),1)*mMc(isn(end));
% end
%% smoothing!
% try
%     [x_smo, S_smo, mMc_smooth]=fct_gen_SmoothHann(timeline,mMc,params.smoothDayFac);
%     Mc = [timeline' mMc_smooth];
% catch
%     warning('smoothing failed')
McVf = [timeline' mMc];
% end

%% final
% Mc = [timeline' mMc];
MasterMc.McDaily = McVf;
MasterMc.McDailySmooth = NaN;
MasterMc.McMax = max(McVf(:,2));
MasterMc.McMean = mean(McVf(:,2),'omitnan');
MasterMc.McMedian = median(McVf(:,2),'omitnan');
MasterMc.McMin = min(McVf(:,2));
% disp(['Max Mc: ',num2str(MasterMc.McMax)])

%% make time vs Mc plot
timelineDT = datetime(datevec(timeline));
%     H = mkMcFig(MASTERMc,'on');
H=figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/3],'visible',params.visible); hold on

%% maybe not necessary...
maxEvents2plot=params.maxEvents2plot;
if numel(mags) > maxEvents2plot
    warning(['attempted to plot more than ',int2str(maxEvents2plot),' events, plot may be decimated'])
    mags = mags(2:round(numel(mags)/maxEvents2plot):end);
    dtimes = dtimes(2:round(numel(dtimes)/maxEvents2plot):end);
    w='*';
else
    w=' ';
end
%%
lh ={}; aa = [];
if ~isempty(dtimes)
    a = plot(dtimes,mags,'.','Color',[.5 .5 .5]);
    lh = [lh,'Events']; aa = [aa,a(1)];
end

if isempty(McV.Mc) && isempty(McV.Mc)
        dtws = [];
elseif isempty(McL.Mc)
        dtws = datetime(datevec(McV.Mc(:,1)));
elseif isempty(McV.Mc) 
    dtws = datetime(datevec(McL.Mc(:,1)));
else
    dtws = sort(unique([datetime(datevec(McV.Mc(:,1)));datetime(datevec(McL.Mc(:,1)))]));
end

try
%     for i=1:numel(McV.McChangePts)
%         a =plot([McV.McChangePts(i),McV.McChangePts(i)],[0,6],'Color',[0 .5 0]);
%     end
    a =plot(McV.McChangePts,ones(numel(McV.McChangePts),1)*5,'MarkerEdgeColor',[0 .5 0],'Marker','p','MarkerSize',15,'LineStyle','none');
    lh = [lh,'V ChangePt']; aa = [aa,a(1)];
end

try
%     for i=1:numel(McL.McChangePts)
%         a =plot([McL.McChangePts(i),McL.McChangePts(i)],[0,6],'Color','b');
%     end
    a =plot(McL.McChangePts,ones(numel(McL.McChangePts),1)*5.5,'MarkerEdgeColor','b','Marker','p','MarkerSize',15,'LineStyle','none');
    lh = [lh,'L ChangePt']; aa = [aa,a(1)];
end

for i=1:size(dtws,1)
    plot([dtws(i,1),dtws(i,1)],[0,6],'Color',[.5 .5 .5],'LineStyle',':');
end

a = plot(timelineDT,mMc,'r-','LineWidth',5);
lh = [lh,'MASTER Mc']; aa = [aa,a(1)];

% plot(datetime(datevec(iscmc(:,1))),iscmc(:,2),'Color','r','LineWidth',3)
a =plot(datetime(datevec(McG.McDaily(:,1))),McG.McDaily(:,2),'Color','k','LineWidth',3);
lh = [lh,'ISC Mean Mc'];aa = [aa,a(1)];
% title([vinfo.name,', ',vinfo.country])

a =plot(timelineDT,vmc,'k-','LineWidth',3,'color',[0 .5 0]);
lh = [lh,'ISC Volcano Mc'];aa = [aa,a(1)];

% plot(timelineDT,vmc,'c-','LineWidth',4)
% lh = [lh,'volcano Mc Smooth'];

if ~isempty(McL)
    a =plot(timelineDT,lmc,'b-','LineWidth',3);
    lh = [lh,'Local Mc'];aa = [aa,a(1)];
end

legend(aa,lh)
box on

ylim([0 6])
xlim([timeline(1) MasterMc.McDaily(end,1)])
xlabel('Date')
ylabel('Magnitude')
zoom xon

title([vinfo.name,', ',vinfo.country, ...
    '  (',int2str(numel(dtimes)),w,' events, window = ',int2str(params.McMinN), ...
    ' events, smoothing = ',num2str(params.smoothDays/365),' yrs, radius = ',int2str(params.srad(2)),' km'])

end