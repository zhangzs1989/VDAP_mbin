function mapdata = prep4WingPlot(vinfo,params,input,outer,inner)

disp(mfilename)

if ~isfield(input,'GSHHS')
    input.GSHHS = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/data/gshhs_f.b'; %full res;
    if ~exist(input.GSHHS,'file')
        error('No coastline file')
    end
end

if ~isfield(params,'coasts')
    params.coasts = true;
end

if ~isfield(params,'topo')
    params.topo = false;
end

%% Geographical Plot
longannO = outer(:,2); latannO=outer(:,1);
longannI = inner(:,2); latannI=inner(:,1);

if isfield(params,'mkGMToutput') && params.mkGMToutput
    [mapDataI] = mkGMTsegmentFile(latannI,longannI);
    [mapDataO] = mkGMTsegmentFile(latannO,longannO);
    mapData2 = [mapDataI; mapDataO];
    s6_cellwrite([input.outDir,filesep,vinfo.name,filesep,'mapAnnulus.xy'],mapData2,' ')
end
%%
%map axes
latlim = [min([latannO]) max([latannO])];
lonlim = [min([longannO]) max([longannO])];
[latlim, lonlim] = bufgeoquad(latlim, lonlim, .00775, .00775);

% deal with crossing 180 longitude for semisepochnoi. NOTE only needed for
% 180 to -180, not 0 to -0, i.e. west eifel volcanic field germany
if (sign(min(longannO)) ~= sign(max(longannO)) || sign(min(lonlim)) ~= sign(max(lonlim))) && abs(max(lonlim)) > 100
    warning('avoiding LON meridian bug, NO stations or summits yet!')
    try
        vinfo.lon(vinfo.lon<0) = vinfo.lon(vinfo.lon<0) + 360;
        if isfield(vinfo,'vcoords')
            vinfo.vcoords(vinfo.vcoords(:,2)<0,2) = vinfo.vcoords(vinfo.vcoords(:,2)<0,2) +360;
        end
    end
    %     elong(elong<0) = elong(elong<0) + 360;
    longannO(longannO<0) = longannO(longannO<0) + 360;
    lonlim = [min(longannO) max(longannO)];
    [latlim, lonlim] = bufgeoquad(latlim, lonlim, .00775, .00775);
    lonlim(lonlim<0) = lonlim(lonlim<0)+360  ;
    % else
    %         lonlim = [min([longannO]) max([longannO])];
    %         [latlim, lonlim] = bufgeoquad(latlim, lonlim, .00775, .00775);
end
lonlim = [min(lonlim) max(lonlim)];

% coastline database - full res
if params.coasts
    disp('  coastlines...')
    
    indexname = [input.GSHHS(1:end-1),'i'];
    if ~exist(indexname,'file')
        try
            indexname = gshhs(input.GSHHS, 'createindex');
        catch
            pause(2)
            indexname = gshhs(input.GSHHS, 'createindex');
        end
    end
    try
        mapdata.coastlines = gshhs(input.GSHHS, latlim, lonlim);
    catch
        warning('problem with coastlines')
    end
    %     delete(indexname)
end

% add for topo
if params.topo
    disp('  topo...')
    %     try
    %         layers = wmsfind('nasa.network*elev', 'SearchField', 'serverurl');
    %         layers = wmsupdate(layers);
    %         srtmplus = layers.refine('srtm30', 'SearchField', 'layername');
    %         cellSize = dms2degrees([0 0 10]);
    %         [ZA, RA] = wmsread(srtmplus, 'Latlim', latlim, 'Lonlim', lonlim, ...
    %             'CellSize', cellSize, 'ImageFormat', 'image/bil','RelTolCellSize',0.01);
    %
    %         mapdata.ZA = ZA;
    %         mapdata.RA = RA;
    %     catch
    try % temp fix for NASA server move issue being fixed by matlab 1/5/17
        % NOTE: sometimes wmsinfo hangs on VPN but not always reproducible
        info =wmsinfo('https://data.worldwind.arc.nasa.gov/elev?');
        layers = info.Layer; % instead of layers = wmsfind('nasa.network*elev', 'SearchField', 'serverurl')
        layers = wmsupdate(layers);
        srtmplus = layers.refine('srtm30', 'SearchField', 'layername');
        cellSize = dms2degrees([0 0 10]);
        [ZA, RA] = wmsread(srtmplus, 'Latlim', latlim, 'Lonlim', lonlim, ...
            'CellSize', cellSize, 'ImageFormat', 'image/bil','RelTolCellSize',0.01);
        
        mapdata.ZA = ZA;
        mapdata.RA = RA;
    catch
        warning('TOPO NO BUENO')
    end
    %     end
    
    %% export topo
    if isfield(params,'mkGMToutput') && params.mkGMToutput
        topoOut = mkGMTtopoFile(RA, ZA);
        save([params.outDir,'/',vinfo.name,'/topo.xyz'],'topoOut','-ascii')
    end
end


%%
% stations
if isfield(input,'stas') && ~isempty(input.stas)
    try
        [~,lon,lat,elev] = importSwarmStationConfig(input.stas);
        if sum(~isnan(lon))==0
            [~,lat,lon,elev] = importStationFile(input.stas);
        end
    catch
        [~,lat,lon,elev] = importStationFile(input.stas);
    end
    id_a2 = inpolygon(lon, lat, longannO, latannO);
    mapdata.sta_lat = lat(id_a2);
    mapdata.sta_lon = lon(id_a2);
    mapdata.sta_elev = elev(id_a2);
else
    mapdata.sta_lat = [];
    mapdata.sta_lon = [];
    mapdata.sta_elev = [];
end
mapdata.outer = outer;
mapdata.inner = inner;
mapdata.latlim = latlim;
mapdata.lonlim = lonlim;
mapdata.longann = longannO;
mapdata.latann = latannO;

end
