function [MasterMc,H] = mkMasterMc(vinfo,ISC_McInfo,Mc,localMc,catalog,params)

if isempty(catalog)
    mags = [];
    dtimes = [];
else
    mags = extractfield(catalog,'Magnitude');
    dtimes = datenum(extractfield(catalog,'DateTime'));
end

scrsz = [ 1 1 1080 1920];
timeline = ISC_McInfo.McDaily(1,1):ceil(now);
iscMc = interp1(ISC_McInfo.McDaily(:,1),ISC_McInfo.McDaily(:,2),timeline);
gmc = nan(1,length(timeline));
dtimes = datetime(datevec(dtimes));

if size(Mc.McDaily,1)<2
    vmc = gmc;
    vmc0= gmc;
else
    vmc0= interp1(Mc.McDaily(:,1),Mc.McDaily(:,2),timeline);
    if isfield(Mc,'McDailySmooth')
        vmc = interp1(Mc.McDailySmooth(:,1),Mc.McDailySmooth(:,2),timeline);
    else
        vmc = vmc0;
    end
end

if isempty(localMc)
    lmc = gmc;
elseif size(localMc.McDailySmooth,1)>=2
    lmc = interp1(localMc.McDailySmooth(:,1),localMc.McDailySmooth(:,2),timeline);
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
    Mc = [timeline' mMc];
% end

%% final
% Mc = [timeline' mMc];
MasterMc.McDaily = Mc;
MasterMc.McDailySmooth = NaN;
MasterMc.McMax = max(Mc(:,2));
MasterMc.McMean = mean(Mc(:,2),'omitnan');
MasterMc.McMedian = median(Mc(:,2),'omitnan');
MasterMc.McMin = min(Mc(:,2));
% disp(['Max Mc: ',num2str(MasterMc.McMax)])

%% make time vs Mc plot
timelineDT = datetime(datevec(timeline));
%     H = mkMcFig(MASTERMc,'on');
H=figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/3],'visible',params.visible); hold on

lh ={};
if ~isempty(dtimes)
    plot(dtimes,mags,'k.')
    lh = [lh,'Mags'];
end

ISC_Mc = ISC_McInfo.Mc;
% make stairs for plotting
j=1;
for i=1:length(ISC_Mc)
    iscmc(j,1)=ISC_Mc(i,1);
    iscmc(j+1,1)=ISC_Mc(i,2);
    iscmc(j,2) = ISC_Mc(i,3);
    iscmc(j+1,2)= ISC_Mc(i,3);
    j=j+2;
end
plot(datetime(datevec(iscmc(:,1))),iscmc(:,2),'Color','r','LineWidth',3)
% plot(datetime(datevec(ISC_McInfo.McDaily(:,1))),ISC_McInfo.McDaily(:,2),'Color','k','LineWidth',3)
lh = [lh,'ISC Mc'];
title([vinfo.name,', ',vinfo.country])

plot(timelineDT,vmc0,'k-','LineWidth',1)
lh = [lh,'volcano Mc Raw'];

plot(timelineDT,vmc,'c-','LineWidth',4)
lh = [lh,'volcano Mc Smooth'];

if ~isempty(localMc)
    plot(timelineDT,lmc,'g-','LineWidth',4)
    lh = [lh,'Local Mc'];
end

plot(timelineDT,mMc,'b-','LineWidth',2)
lh = [lh,'MASTER Mc'];

legend(lh)
grid on, box on

ylim([0 6])
xlim([timeline(1) MasterMc.McDaily(end,1)])
xlabel('Date')
ylabel('Magnitude')
zoom xon
% print(gcf,'-dpng',fullfile(outDir,['Mc/MASTER_Mc_',fixStringName(vinfo.name)]))
% close(gcf)
end