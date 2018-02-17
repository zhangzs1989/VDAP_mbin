function [ McG,McL,MasterMc ] = buildMcbyVolcano(catalogMaster,catalogISC,catalogLocal,vinfo,params,vpath)

[~,~,~] = mkdir(vpath);

ISC_McFile = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/ISC_Mc.csv';
McG = getGlobalISC_McInfo(ISC_McFile);

%% step 1: get volcano Mc from Global catalogs
str='ISC';
McV = getVolcanoMc2(vinfo,catalogISC,vpath,params,str);

outMcInfoName=fullfile(vpath,['Mc_',str,'_',int2str(vinfo.Vnum),'.mat']);
parsave_struct(outMcInfoName,McV);

%% step 2: get regional/local Mc from any other source
str='LOCAL';
McL = getVolcanoMc2(vinfo,catalogLocal,vpath,params,str);

outMcInfoName=fullfile(vpath,['Mc_',str,'_',int2str(vinfo.Vnum),'.mat']);
parsave_struct(outMcInfoName,McL);

%% step 3: combine & compute MASTER Mc
[MasterMc,H] = mkMasterMc2(vinfo,McG,McV,McL,catalogMaster,params);

print(H,'-dpng',fullfile(vpath,['Mc_MASTER_',fixStringName(vinfo.name)]))
savefig(H,fullfile(vpath,['Mc_MASTER_',fixStringName(vinfo.name)]))

outMcInfoName=fullfile(vpath,['Mc_MASTER_',int2str(vinfo.Vnum),'.mat']);
parsave_struct(outMcInfoName,MasterMc);

end