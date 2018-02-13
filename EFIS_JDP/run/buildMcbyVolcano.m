function [ Mc, MasterMc ] = buildMcbyVolcano(catalog,vinfo,params,input)

vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
[~,~,~] = mkdir(vpath);

%% TODO: worry about when local catalog is included, need to smooth less and not at transition
Mc = getVolcanoMc(vinfo,catalog,vpath,params.McMinN,'MASTER',4,params.smoothDayFac);
ISC_McFile = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/ISC_Mc.csv';
ISC_McInfo = getGlobalISC_McInfo(ISC_McFile);

outMcInfoName=fullfile(vpath,['Mc_',int2str(vinfo.Vnum),'.mat']);
parsave_struct(outMcInfoName,Mc);

%% compute MASTER Mc
[MasterMc,H] = mkMasterMc(vinfo,ISC_McInfo,Mc,[],catalog,params);
set(get(H(1).Children(2),'title'),'String',[vinfo.name,', ',vinfo.country,'  (',int2str(numel(catalog)),' events, window = ',int2str(params.McMinN),' events, smoothing = ',num2str(params.smoothDayFac/365),' yrs, radius = ',int2str(params.srad(2)),' km'])
print(H,'-dpng',fullfile(vpath,['Mc_MASTER_',fixStringName(vinfo.name)]))
savefig(H,fullfile(vpath,['Mc_MASTER_',fixStringName(vinfo.name)]))
outMcInfoName=fullfile(vpath,['Mc_MASTER_',int2str(vinfo.Vnum),'.mat']);
parsave_struct(outMcInfoName,MasterMc);

end