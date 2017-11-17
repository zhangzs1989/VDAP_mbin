clearvars -except

input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/global7'; % importISCcatalog.m
% input.polygonFilter = 'United States';
input.outDir = '~/Dropbox/Research/EFIS/global7';
% params.polygonFilterSwitch = 'out';
% smoothFac = 0.5;
%%
load(input.gvp_volcanoes)
% [volcanoCat,XV,YV]= regionalCatalogFilter(input,volcanoCat,params);
%%
ISC_McFile = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/ISC_Mc.csv';
ISC_McInfo = getGlobalISC_McInfo(ISC_McFile);
% H = mkMcFig(ISC_McInfo,'on');
timeline = ISC_McInfo.McDaily(1,1):ceil(now);
iscMc = interp1(ISC_McInfo.McDaily(:,1),ISC_McInfo.McDaily(:,2),timeline);
% Mc(:,1) = timeline;
scrsz = [ 1 1 1080 1920];
gmc = nan(1,length(timeline));
        
%% FIND specific volcano if desired
% vname = 'Soufrière Hills';
% vnames = extractfield(volcanoCat,'Volcano');
% vi = find(strcmpi(vname,vnames));
% volcanoCat = volcanoCat(vi);
%%
for i=1:numel(volcanoCat)
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    outDir = fullfile(input.outDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    [~,~,~] = mkdir(outDir);
    disp([int2str(i),'/',int2str(numel(volcanoCat)),', ',vinfo.name,', ',vinfo.country])
    
    [McStatus,catNames]= check4catalogMcs(vpath,vinfo.Vnum);
    outFile = fullfile(outDir,catNames(4));
    
    if McStatus(1) ~= 2
        error('No ISC Mc File')
    else
        vISCMc = load(fullfile(vpath,catNames{1}));
%         H = mkMcFig(vISCMc,'on');
        if ~isfield(vISCMc,'McMax')
            error('FATAL')
        end
    end
    if size(vISCMc.McDaily,1)<2
        vmc = gmc;
    else
        vmc = interp1(vISCMc.McDailySmooth(:,1),vISCMc.McDailySmooth(:,2),timeline);
    end
    
%     if McStatus(4)==2
%         warning('Overwriting existing MASTER Mc file')
%     end
%     
    if McStatus(3)~=2
        disp('No local Mc exists')
        lmc = gmc;
    else
        localMc = load(fullfile(vpath,catNames{3}));
%         H = mkMcFig(localMc,'on');
        if size(localMc.McDailySmooth,1)>=2
            lmc = interp1(localMc.McDailySmooth(:,1),localMc.McDailySmooth(:,2),timeline);
        else
            lmc = gmc;            
        end
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
    MASTERMc.McDaily = Mc;
    MASTERMc.McDailySmooth = NaN;
    MASTERMc.McMax = max(Mc(:,2));
    MASTERMc.McMean = mean(Mc(:,2),'omitnan');
    MASTERMc.McMedian = median(Mc(:,2),'omitnan');
    MASTERMc.McMin = min(Mc(:,2));
    disp(['Max Mc: ',num2str(MASTERMc.McMax)])
%     H = mkMcFig(MASTERMc,'on');

    save(fullfile(vpath,'Mc',['MASTER_McInfo_',int2str(vinfo.Vnum),'.mat']),'-struct','MASTERMc');
    
    %% make time vs Mc plot
    %     H = mkMcFig(MASTERMc,'on');    
    figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/3],'visible','on'); hold on  
    plot(ISC_McInfo.McDaily(:,1),ISC_McInfo.McDaily(:,2),'Color',[.5 .5 .5],'LineWidth',3)
    lh ={};
    lh = [lh,'ISC Mc'];
    title([vinfo.name,', ',vinfo.country])
    
    plot(timeline,vmc,'b-','LineWidth',3)
    lh = [lh,'volcano ISC Mc'];
    
    plot(timeline,lmc,'g-','LineWidth',3)
    lh = [lh,'Local Mc'];
    
    plot(timeline,mMc,'r-','LineWidth',2)
    lh = [lh,'MASTER Mc'];
    
    legend(lh)
    datetick, grid on, box on
    ylim([0 6])
    xlim([timeline(1) MASTERMc.McDaily(end,1)])
    zoom xon
    print(gcf,'-dpng',fullfile(outDir,['Mc/MASTER_Mc_',fixStringName(vinfo.name)]))
    close(gcf)
    
end