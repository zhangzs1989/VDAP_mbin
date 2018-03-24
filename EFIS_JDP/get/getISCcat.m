function catalog = getISCcat(input,params,vinfo,mapdata,varargin)

volcOutName = fixStringName(vinfo.name);

% files pulled from ISC can be empty and still succesfull pull
if nargin >= 5 %new eruption usages
    
    qual = varargin{1};
    qual = validatestring(qual,{'COMPREHENSIVE','REVIEWED'}, mfilename, 'qual');
    if ~ischar(varargin{2}); error('bad input'); end;
    outDirName = fullfile(varargin{2});
    
    t1 = params.YearRange(1); t2 = params.YearRange(2);
    yr1 = str2int(datestr(t1,'yyyy')); mo1 = str2int(datestr(t1,'mm')); dy1 = str2int(datestr(t1,'dd'));
    yr2 = str2int(datestr(t2,'yyyy')); mo2 = str2int(datestr(t2,'mm')); dy2 = str2int(datestr(t2,'dd'));
    
else % original use
    qual = 'COMPREHENSIVE';
    outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
    yr1=params.YearRange(1);
    mo1=1;dy1=1;
    yr2=params.YearRange(2)+1;
    mo2=1;dy2=1;
end
%% this function pulls an ISC catalog for a radius around a point
% outDirName=fullfile(input.catalogsDir,fixStringName(vinfo.country),volcOutName);
outCatName=fullfile(outDirName,['cat_ISC_',int2str(vinfo.Vnum)]);
odir = outDirName;
[~,~,~] = mkdir(odir);

if exist([outCatName,'.mat'],'file') %&& ~params.getCats
    disp('loading old m-catalog...')
    catalog = load(outCatName);
    catalog = catalog.catalog;
    return
end
%%
warning('on','all')
% NOTE: 40,000 event limit for wget pull!
yrInc = 5;

shscript='~/bin/wgetISC_both.sh';
% shscript2='~/bin/wgetISC_MTs.sh';
reducFac = (2/3);

lat=vinfo.lat;
lon=vinfo.lon;
if numel(params.srad)==2
    rad=params.srad(2);
else
    rad = params.srad(1);
end
depMax=params.DepthRange(2);
minMag=params.MagRange(1);

ofile = fullfile(odir,['ISC_CAT_',volcOutName,'.csv']);
ofileL = fullfile(odir,['ISC_CAT_',volcOutName,'.log']);

ofileMT = fullfile(odir,['ISC_FM_',volcOutName,'.csv']);
ofileMTl = fullfile(odir,['ISC_FM_',volcOutName,'.log']);

% s = dir(ofile);
% s2 = dir(ofileMT);
maxEvFlag = false;
erStr = 'Sorry';

%% MT catalog
if ~exist(ofileMT,'file') || ~exist(ofileMTl,'file')
    disp(['getting MT catalog from ISC...'])
    tag = 'FM';
    [status,result] = wgetGrabISCfile(shscript,volcOutName,...
        lat,lon,rad,depMax,minMag,yr1,mo1,dy1,yr2,mo2,dy2,qual,tag,odir,ofileMT,ofileMTl,tag);
    
    if status > 0
        pause(5) % pause and try again
        [status,result] = wgetGrabISCfile(shscript,volcOutName,...
            lat,lon,rad,depMax,minMag,yr1,mo1,dy1,yr2,mo2,dy2,qual,tag,odir,ofileMT,ofileMTl,tag);
    end
    
else
    disp('using existing ISC MT catalog')
end
FMcatalog = import1ISC_MTfile(ofileMT);
%% EQ catalog
if ~exist(ofile,'file') || ~exist(ofileL,'file')
    
    disp(['getting catalog from ISC...'])
    tag='CAT';
    [status,result] = wgetGrabISCfile(shscript,volcOutName,...
        lat,lon,rad,depMax,minMag,yr1,mo1,dy1,yr2,mo2,dy2,qual,tag,odir,ofile,ofileL,tag);
    
    if status > 0
        pause(5) % pause and try again
        [status,result] = wgetGrabISCfile(shscript,volcOutName,...
            lat,lon,rad,depMax,minMag,yr1,mo1,dy1,yr2,mo2,dy2,qual,tag,odir,ofile,ofileL,tag);
    end
    
    if any(strfind(result,'exceeds'))
        warning('TOO MANY EVENTS!') % TODO: this needs a loop and a sub function
        %NOW WHAT? reduce radius
        maxEvFlag = true;
        
        for yr = yr1:yrInc:yr2
            disp(['Year ',int2str(yr),' to ',int2str(yr+yrInc)])
            [status,result] = wgetGrabISCfile(shscript,volcOutName,...
                lat,lon,rad*reducFac,depMax*reducFac,minMag,yr,1,1,yr+yrInc,1,1,qual,tag,odir,ofile,tag);
            ofile1 = fullfile(odir,['ISC_',volcOutName,'_',int2str(yr),'.csv']);
            cmd = sprintf('cp %s %s',ofile,ofile1);
            [~,~] = system(cmd);
        end
    end
    
end
%%
if ~exist(ofile,'file')
    catalog = [];
    warning('NO ISC FILE EXISTS AFTER TWO ATTEMPTS!')
    return
end
%%
disp('importing ISC formatted catalog...')
if ~maxEvFlag
    catalog = import1ISCfile(ofile);
    catalog = rmDuplicateEvents(catalog,0);
else
    %combine yr catalogs
    catalog = [];
    for yr = yr1:yrInc:yr2
        disp(['Year ',int2str(yr),' to ',int2str(yr+yrInc)])
        ofile1 = fullfile(odir,['ISC_',volcOutName,'_',int2str(yr),'.csv']);
        catalog1 = import1ISCfile(ofile1);
        catalog1 = rmDuplicateEvents(catalog1,0);
        catalog = [catalog;catalog1];
    end
end
catalog = addFMs2catalog(catalog,FMcatalog);

save(outCatName,'catalog');
%% PLOT
if params.wingPlot
    t1a=datenum(yr1,mo1,dy1);
    t2a=datenum(yr2,mo2,dy2);
    catalog = filterTime( catalog, t1a, t2a);% wingplot ISC
    figname=fullfile(outDirName,['map_ISC_',volcOutName]);
    fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
    close(fh_wingplot)
end

end
%%
function [status,result] = wgetGrabISCfile(shscript,volcOutName,...
    lat,lon,rad,depMax,minMag,yr1,mo1,dy1,yr2,mo2,dy2,qual,tag,odir,ofile,ofileL,str)

erStr = 'Sorry';

cmd = sprintf('%s %s %f %f %d %d %f %d %d %d %d %d %d %s %s %s',...
    shscript,volcOutName,lat,lon,rad,depMax,minMag,yr1,mo1,dy1,yr2,mo2,dy2,qual,tag,odir);
[status,result] = system(cmd);

cmd2 = sprintf('echo "%s" > %s/ISC_%s_Request.sh',cmd,odir,str);
[~,~] = system(cmd2);
% disp(result)

if any(strfind(result,erStr)) % try again b/c sometimes wget errors at ISC are a fluke
    disp(result)
    warning('wget pull failed')
    cmd = sprintf('rm -f %s',ofile);
    [~,~] = system(cmd);
    cmd = sprintf('rm -f %s',ofileL);
    [~,~] = system(cmd);
    status = status + 1;
end

if status > 0  %what does 1 mean? seems ok sometimes but 0 bad sometimes??
    disp(result)
    warning(['status = ',int2str(status)])
end

end
%%
function catalog = addFMs2catalog(catalog,FMcatalog)

if ~isempty(FMcatalog)
    FMID = extractfield(FMcatalog,'EVENT_ID');
    EVID = extractfield(catalog,'EVENTID');
    
    for l=1:length(FMID)
        I=find(FMID(l)==EVID);
        if ~isempty(I)
            catalog(I).MT = FMcatalog(l);
        elseif length(I)>1
            disp('MORE THAN ONE FM returned, taking first')
            catalog(I(1)).MT = FMcatalog(l);
        end
    end
end

end