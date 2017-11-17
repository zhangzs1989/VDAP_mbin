clear

input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
% input.ISCcatalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/trimISCcatalog2volcs/iscCatalogAll5wFMsTrim.mat'; % importISCcatalog.m
input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/global7'; % importISCcatalog.m
input.outDir = '~/Dropbox/Research/EFIS/global7';
% input.polygonFilter = 'United States';

%% general params
params.srad = [0 50];
params.DepthRange = [-3 40]; % km
params.MagRange = [0 10];
params.YearRange = [1964 2015];
params.polygonFilterSwitch = 'out';
% params.polygonBuffer = 2; % in degrees

%% wingPlot params
params.coasts = true;
params.wingPlot = false;
params.topo = true;
params.visible = 'off';
%%
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')
disp(params)
%%
load(input.gvp_volcanoes)
% [volcanoCat,~,~]= regionalCatalogFilter(input,volcanoCat,params);
% volcanoCat = filterCatalogByCountry(volcanoCat,input.polygonFilter,params.polygonFilterSwitch);
%%
[result,status,probCountries,probVolcanoes,I] = checkCatalogDBintegrity(input.catalogsDir,volcanoCat);

%% FIND specific volcano if desired
vname = 'Arshan';
vnames = extractfield(volcanoCat,'Volcano');
vi = find(strcmp(vname,vnames));
volcanoCat = volcanoCat(vi);
%%
for i=1:numel(volcanoCat)
    
    [vinfo] = getVolcanoInfo(volcanoCat,[],i);
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    outDir = fullfile(input.outDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    [~,~,~] = mkdir(outDir);
    outVinfoName=fullfile(outDir,['vinfo_',int2str(vinfo.Vnum),'.mat']);
    save(outVinfoName,'-struct','vinfo');
    
    disp([int2str(i),'/',int2str(numel(volcanoCat)),', ',vinfo.name,', ',vinfo.country])
    
    %%
    % make master catalog from others
    % only 4 types so far, MASTER, ISC, ANSS, local
    [CatalogStatus,catNames] = check4catalogs(vpath,vinfo.Vnum);
    
    %ISC
    if CatalogStatus(1)~=2
        error('No ISC catalog')
    else
        catISC=load(fullfile(vpath,char(catNames(1))));
        catISC = catISC.catalog;
        catMASTER = catISC;
    end
    
    % ANSS
    if CatalogStatus(2)==2
        catANSS=load(fullfile(vpath,char(catNames(2))));
        catANSS = catANSS.catalog;
        % try to merge ISC and ANSS (not really necessary but test)
        [catMASTER,H] = mergeTwoCatalogs(catISC,catANSS,'yes');
        if ~isempty(H); print(H,fullfile(outDir,'ANSS_MergeQC'),'-dpng'); end;
    end
    
    % Local
    if CatalogStatus(3)==2
        catLocal=load(fullfile(vpath,char(catNames(3))));
        catLocal = catLocal.catalog;
        % merge with local cat
        [catMASTER,H] = mergeTwoCatalogs(catMASTER,catLocal,'fig');
        if ~isempty(H); print(fullfile(outDir,'local_MergeQC'),'-dpng'); end;
        %     else
        %         error('No local catalog, why update?')
    end
    
    %%
    catalog = catMASTER;
    if ~isempty(catMASTER)
        %         dts = extractfield(catMASTER,'DateTime');
        %         [Y,I] = sort(datenum(dts));
        %% FINAL CATALOG
        catalog = filterDepth( catalog, params.DepthRange); % (d)
        catalog = filterMag( catalog, params.MagRange); % (e)
        %    catalog = filterTime( catalog, datenum('1990/01/01'), params.catalogEndDate); % start here to cut out redoubt for now
        catalog = filterAnnulusm( catalog, vinfo.lat,vinfo.lon, params.srad); % (e)
    end
    outCatName=fullfile(outDir,['MASTER_',int2str(vinfo.Vnum),'.mat']);
    save(outCatName,'catalog');
    %% QC
    if params.wingPlot
        [ outer_ann, inner_ann ] = getAnnulusm( volcanoCat(i).Latitude, volcanoCat(i).Longitude, params.srad);
        mapdata = prep4WingPlot(vinfo,params,input,outer_ann,inner_ann);
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        figname=fullfile(outDir,['MASTER_',fixStringName(vinfo.name)]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        close(fh_wingplot)
        F2 = catalogQCmap(catalog,vinfo,params,mapdata);
        print(F2,fullfile(outDir,['MASTER_',int2str(vinfo.Vnum),'_QC2']),'-dpng')
        close(F2)
    end
    %
    if ~isempty(catalog)
        F1 = catalogQCfig(catalog,vinfo,[],[],params.visible);
        print(F1,fullfile(outDir,['MASTER_',int2str(vinfo.Vnum),'_QC1']),'-dpng')
        close(F1)
    end

    
    %% update Mc
    %     Mcpath=fullfile(vpath,'Mc');
    %     [status,catNames] = check4catalogMcs(Mcpath,vinfo.Vnum);
    %     cinfo = getVolcanoMc(vinfo,catalog,outDir,params.McMinN);
    %     outCinfoName=fullfile(outDir,['cinfo_',int2str(vinfo.Vnum),'.mat']);
    %     save(outVinfoName,'-struct','vinfo');
    %     %
    
end
