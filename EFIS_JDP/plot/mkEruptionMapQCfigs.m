function mkEruptionMapQCfigs(catalog,einfo,vinfo,mapdata,params,vpath)

if isempty(einfo)
    return
end
dts = datenum(extractfield(catalog,'DateTime'));
t1min = min(dts);
t1a = min([t1min,datenum(params.YearRange(1),1,1)]);
t2a=datenum(params.YearRange(2)+1,1,1);
%%
%loop over eruptions
%1
t1=t1a; t2=datenum(einfo(1).StartDate);
figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
print(fh_wingplot,'-dpng',[figname,'.png'])
% middle
if numel(einfo)>1
    for e=2:numel(einfo)
        t1=datenum(einfo(e-1).EndDate); t2=datenum(einfo(e).StartDate);
        figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
        fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
        print(fh_wingplot,'-dpng',[figname,'.png'])
    end
    %last
    t1 = datenum(einfo(e).EndDate); t2 = t2a;
    figname=fullfile(vpath,['map_MASTER_',fixStringName(vinfo.name),'_',datestr(t2,'yyyymmdd')]);
    fh_wingplot = wingPlot1(vinfo, t1, t2, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[figname,'.png'])
end

end