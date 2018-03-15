function catalog = getISCcat(input,params,vinfo,mapdata)

%% this function pulls an ISC catalog for a radius around a point
warning('on','all')

shscript='~/bin/wgetISC.sh';
shscript2='~/bin/wgetISC_MTs.sh';
volcOutName = fixStringName(vinfo.name);
outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
outCatName=fullfile(outDirName,['cat_ISC_',int2str(vinfo.Vnum)]);
odir = outDirName;
ofile = fullfile(odir,['ISC_',volcOutName,'.csv']);
ofileMT = fullfile(odir,['iscMT_',volcOutName,'.csv']);
s = dir(ofile);
% s2 = dir(ofileMT);
erStr = 'Sorry';
%%
if ~exist(ofileMT,'file') %|| s2.bytes == 0
    cmd = sprintf('%s %s %f %f %d %d %s',shscript2,volcOutName,vinfo.lat,vinfo.lon,params.srad(2),params.DepthRange(2),odir);
    [status,result] = system(cmd);
    disp(result)
    
    cmd2 = sprintf('echo "%s" > %s/ISC_RequestMT.sh',cmd,odir);
    [status,result] = system(cmd2);
    disp(result)
    
    if ~exist(ofile,'file')
        warning('problem with ISC wget command')
        disp(result)
    end
    
    %%
else
    warning('using existing ISC MT catalog')
end
%%
if ~exist(ofile,'file') || s.bytes == 0
    disp(['getting catalog from ISC...'])
    
    %%
    cmd = sprintf('%s %s %f %f %d %d %s',shscript,volcOutName,vinfo.lat,vinfo.lon,params.srad(2),params.DepthRange(2),odir);
    [status,result] = system(cmd);
    disp(result)
    if any(strfind(result,erStr))
        cmd = sprintf('rm -f %s',ofile);
    end
    
    if status > 0  %what does 1 mean? seems ok sometimes
        warning('wget issue')
    end
    
    cmd2 = sprintf('echo "%s" > %s/ISC_Request.sh',cmd,odir);
    [status,result] = system(cmd2);
    disp(result)
    
    if ~exist(ofile,'file')
        warning('problem with ISC request')
        disp(result)
    end
else
    warning('using existing ISC catalog')
    
    s = dir(ofile);
    try
        catalog = load(outCatName);
        catalog = catalog.catalog;
    catch
        disp('importing ISC formatted catalog...')
        catalog = import1ISCfile(ofile);
        if numel(catalog)>1
            catalog = rmDuplicateEvents(catalog,0);
            FMcatalog = import1ISC_MTfile(ofileMT);
            
            if ~isempty(FMcatalog)
                FMID = extractfield(FMcatalog,'EVENT_ID');
                EVID = extractfield(catalog,'EVENTID');
                
                for l=1:length(FMID)
                    I=find(FMID(l)==EVID);
                    if ~isempty(I)
                        catalog(I).MT = FMcatalog(l);
                    elseif length(I)>1
                        warning('MORE THAN ONE FM returned, taking first')
                        catalog(I(1)).MT = FMcatalog(l);
                    end
                end
            end
        else
            warning('no events imported')
            catalog = [];
        end
        save(outCatName,'catalog');
    end
    if params.wingPlot
        t1a=datenum(params.YearRange(1),1,1);
        t2a=datenum(params.YearRange(2)+1,1,1);
        catalog = filterTime( catalog, t1a, t2a);% wingplot ISC
        figname=fullfile(outDirName,['map_ISC_',volcOutName]);
        fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
        close(fh_wingplot)
    end
    
end

end
