function [MasterMc,H] = mkMasterMc(vinfo,ISC_McInfo,vISCMc,localMc,mags,dtimes,viz)

scrsz = [ 1 1 1080 1920];
timeline = ISC_McInfo.McDaily(1,1):ceil(now);
iscMc = interp1(ISC_McInfo.McDaily(:,1),ISC_McInfo.McDaily(:,2),timeline);
gmc = nan(1,length(timeline));
dtimes = datetime(datevec(dtimes));

if size(vISCMc.McDaily,1)<2
    vmc = gmc;
else
    vmc = interp1(vISCMc.McDailySmooth(:,1),vISCMc.McDailySmooth(:,2),timeline);
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
mMc = min(mMc,[],2);
%% extrapolate end value to today
isn = find(~isnan(mMc));
endrange=isn(end):length(mMc);
mMc(endrange)=ones(length(endrange),1)*mMc(isn(end));
%% final
Mc = [timeline' mMc];
MasterMc.McDaily = Mc;
MasterMc.McDailySmooth = NaN;
MasterMc.McMax = max(Mc(:,2));
MasterMc.McMean = mean(Mc(:,2),'omitnan');
MasterMc.McMedian = median(Mc(:,2),'omitnan');
MasterMc.McMin = min(Mc(:,2));
disp(['Max Mc: ',num2str(MasterMc.McMax)])

%% make time vs Mc plot
timelineDT = datetime(datevec(timeline));
%     H = mkMcFig(MASTERMc,'on');
H=figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/3],'visible',viz); hold on

lh ={};
if ~isempty(dtimes)
    plot(dtimes,mags,'k.')
    lh = [lh,'Mags'];
end

plot(datetime(datevec(ISC_McInfo.McDaily(:,1))),ISC_McInfo.McDaily(:,2),'Color',[.5 .5 .5],'LineWidth',3)
lh = [lh,'ISC Mc'];
title([vinfo.name,', ',vinfo.country])

plot(timelineDT,vmc,'b-','LineWidth',3)
lh = [lh,'volcano ISC Mc'];

if ~isempty(localMc)
    plot(timelineDT,lmc,'g-','LineWidth',3)
    lh = [lh,'Local Mc'];
end

plot(timelineDT,mMc,'r-','LineWidth',2)
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