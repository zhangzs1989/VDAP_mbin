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
mMc = [iscMc',vmc',lmc'];
mMc = min(mMc,[],2,'omitnan');
% mMc = vmc';

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
lh ={};
if ~isempty(dtimes)
    plot(dtimes,mags,'.','Color',[.5 .5 .5])
    lh = [lh,'Events'];
end

plot(timelineDT,mMc,'r-','LineWidth',5)
lh = [lh,'MASTER Mc'];

% ISC_Mc = McG.Mc;
% make stairs for plotting
% j=1;
% for i=1:length(ISC_Mc)
%     iscmc(j,1)=ISC_Mc(i,1);
%     iscmc(j+1,1)=ISC_Mc(i,2);
%     iscmc(j,2) = ISC_Mc(i,3);
%     iscmc(j+1,2)= ISC_Mc(i,3);
%     j=j+2;
% end
% plot(datetime(datevec(iscmc(:,1))),iscmc(:,2),'Color','r','LineWidth',3)
plot(datetime(datevec(McG.McDaily(:,1))),McG.McDaily(:,2),'Color',[.5 .5 .5],'LineWidth',3)
lh = [lh,'ISC Mean Mc'];
% title([vinfo.name,', ',vinfo.country])

plot(timelineDT,vmc,'k-','LineWidth',3)
lh = [lh,'ISC Volcano Mc'];

% plot(timelineDT,vmc,'c-','LineWidth',4)
% lh = [lh,'volcano Mc Smooth'];

if ~isempty(McL)
    plot(timelineDT,lmc,'b-','LineWidth',3)
    lh = [lh,'Local Mc'];
end

legend(lh)
grid on, box on

ylim([0 6])
xlim([timeline(1) MasterMc.McDaily(end,1)])
xlabel('Date')
ylabel('Magnitude')
zoom xon

title([vinfo.name,', ',vinfo.country, ...
    '  (',int2str(numel(dtimes)),w,' events, window = ',int2str(params.McMinN), ...
    ' events, smoothing = ',num2str(params.smoothYrs),' yrs, radius = ',int2str(params.srad(2)),' km'])

% set(get(H(1).Children(2),'title'),'String',[vinfo.name,', ',vinfo.country, ...
%     '  (',int2str(numel(catalogMaster)),' events, window = ',int2str(params.McMinN), ...
%     ' events, smoothing = ',num2str(params.smoothYrs),' yrs, radius = ',int2str(params.srad(2)),' km'])

% print(gcf,'-dpng',fullfile(outDir,['Mc/MASTER_Mc_',fixStringName(vinfo.name)]))
% close(gcf)
end