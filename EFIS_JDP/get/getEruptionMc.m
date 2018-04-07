function [McInfo,catalog] = getEruptionMc(einfo,vinfo,input,params,catalog)

%% local
daysBeforeEruption = params.daysBeforeEruption;

% time window
t1 = datestr(datenum(einfo.StartDate) - daysBeforeEruption); %plot start time
t1 = datenum(t1);
t2 = datenum(einfo.StartDate)+params.daysAfterEruption; % NEW END!! -thus including whole day of eruption
volcname  = fixStringName(vinfo.name);
try
    str = [volcname,'_',int2str(einfo.eruptID)];
catch
    str = [volcname,'_',int2str(einfo.eruption_id)];    
end
% radial window
[ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon, params.srad);
mapdata = prep4WingPlot(vinfo,[],input,outer_ann,inner_ann);

catalog = filterTime(catalog,t1,t2);
catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)

McInfo = getMcInWindow(t1,t2,catalog,params.McMinN,fullfile(input.outDir,str),'');
%%
if isempty(McInfo.Mc)
    %% regional  NOTE: hardwired param factors!
    params.srad = round(params.srad*1.5);
    daysBeforeEruption = round(params.daysBeforeEruption * 1.5);
    params.DepthRange(2) = round(params.DepthRange(2)*1.5);
    
    % time window
    t1 = datestr(datenum(einfo.StartDate) - daysBeforeEruption); %plot start time
    t1 = datenum(t1);
    t2 = datenum(einfo.StartDate)+params.daysAfterEruption; % NEW END!! -thus including whole day of eruption
    
    % radial window
    [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon,params.srad);
    mapdata = prep4WingPlot(vinfo,[],input,outer_ann,inner_ann);

    %     catalog = getLocalCatalog(catalogs,input,params,vinfo,mapdata,vinfo.country);
    catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)
    
    McInfo = getMcInWindow(t1,t2,catalog,params.McMinN,input.outDir,str);
    
end

if isempty(McInfo.Mc)
    %% global NOTE: hardwired param factors!
    params.srad = 200; %params.srad*2;
    daysBeforeEruption = 365*2; %params.daysBeforeEruption * 2;
    params.DepthRange(2) = 200; %params.DepthRange(2)*2;
    
    % time window
    t1 = datestr(datenum(einfo.StartDate) - daysBeforeEruption); %plot start time
    t1 = datenum(t1);
    % extend to end date here, b/c you are only using REVIEWED data, so no
    % local events will make it in.
    t2 = datenum(einfo.EndDate)+params.daysAfterEruption; % NEW END!! -thus including whole day of eruption
    
    % radial window
%     [ outer_ann, inner_ann ] = getAnnulusm( vinfo.lat, vinfo.lon,params.srad);
%     mapdata = prep4WingPlot(vinfo,[],input,outer_ann,inner_ann);
    
    params.YearRange = [t1 t2];
    
%     catalog = getISCcat(input,params,vinfo,mapdata,'REVIEWED',fullfile(input.outDir,str));
    catalog = load(fullfile(input.catalogsDir,fixStringName(vinfo.country),volcname,['cat_ISCr_',int2str(vinfo.Vnum),'.mat']));
    catalog = catalog.catalog;
    
    catalog = filterTime(catalog,t1,t2);
%     catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)
%     catalog = filterDepth(catalog,params.DepthRange);
    
    McInfo = getMcInWindow(t1,t2,catalog,params.McMinN,input.outDir,str);
    
end

if params.wingPlot && ~isempty(McInfo.Mc)

    F1 = catalogQCfig(catalog,vinfo,einfo,McInfo.McDaily,params.visible,t1,t2);
    [~,~,~] = mkdir([input.outDir,'/',str]);
    fname=fullfile(input.outDir,str,'QC');
    print(F1,fname,'-dpng')
    %         try savefig(F1,fname); catch; warning('savefig error'); end
    
    fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[input.outDir,'/',str,'/map'])
    close(F1); close(fh_wingplot)
end

end
