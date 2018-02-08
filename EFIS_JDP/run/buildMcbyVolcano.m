function [ Mc, MasterMc ] = buildMcbyVolcano(catalog,vinfo,params,input)

vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
[~,~,~] = mkdir(vpath);
McPath = fullfile(vpath,'Mc');
[~,~,~] = mkdir(McPath);

Mc = getVolcanoMc(vinfo,catalog,McPath,params.McMinN,'MASTER',2,params.smoothDayFac);
ISC_McFile = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/ISC_Mc.csv';
ISC_McInfo = getGlobalISC_McInfo(ISC_McFile);

outMcInfoName=fullfile(McPath,['McInfo_',int2str(vinfo.Vnum),'.mat']);
parsave_struct(outMcInfoName,Mc);
%% make time vs Mc plot
mags = extractfield(catalog,'Magnitude');
dtimes = datenum(extractfield(catalog,'DateTime'));
% H = mkMcFig(Mc,mags,dtimes,params.visible);
% set(get(H(1).Children(2),'title'),'String',[vinfo.name,', ',vinfo.country,'  (',int2str(length(mags)),' events, window = ',int2str(params.McMinN),' events, smoothing = ',num2str(params.smoothDayFac/365),' yrs, radius = ',int2str(params.srad(2)),' km'])
% print(H,'-dpng',fullfile(McPath,['Mc_',fixStringName(vinfo.name)]))
% savefig(H,fullfile(McPath,['Mc_',fixStringName(vinfo.name)]))

%% compute MASTER Mc
[MasterMc,H] = mkMasterMc(vinfo,ISC_McInfo,Mc,[],mags,dtimes,params.visible);
print(H,'-dpng',fullfile(McPath,['MASTER_Mc_',fixStringName(vinfo.name)]))
savefig(H,fullfile(McPath,['MASTER_Mc_',fixStringName(vinfo.name)]))
outMcInfoName=fullfile(McPath,['MASTER_McInfo_',int2str(vinfo.Vnum),'.mat']);
%     save(outMcInfoName,'-struct','MasterMc');
parsave_struct(outMcInfoName,MasterMc);

end