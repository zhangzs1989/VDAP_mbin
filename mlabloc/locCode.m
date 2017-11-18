function locCode(inputFile)
%{
THIS IS THE MAIN LOCATION CODE THAT TAKES IN QUAKEML PICK FILES OUTPUT FROM
SWARM AND LOCATES THEM USING A FULL BRUTE FORCE GRID SEARCH. THE FUNCTION
REQUIRES A TEXT FILE THAT DEFINES MATLAB PARAMS AND INPUTS INCLUDING A FILE
THAT LISTS THE QUAKEML FILES TO BE LOCATED

THIS IS AN EXAMPLE OF THE TEXT FILE TO BE READ IN BY THE locCode.m:
--
%% this text file is read into matlab and the variables are created
inputs.summit = [115.508,-8.343,2995]; %lon,lat,elevation of summit
inputs.str = 'Agung'; %used for naming outputs
inputs.stations= '/Users/jpesicek/Dropbox/VDAP/Responses/Agung/stations/LatLonAgung11.config'; % swarm config format
inputs.velFile='/Users/jpesicek/Dropbox/sw/swarm-2.8.1-SNAPSHOT/DefaultVelocityModel.txt'; % swarm/HYPO71 format
inputs.quakeMLfileList='/Users/jpesicek/Dropbox/VDAP/Responses/Agung/fromWMnov8/quakemllist.txt'; % list of quakeml file paths
inputs.outDir='/Users/jpesicek/Dropbox/VDAP/Responses/Agung/fromWMnov8'; % output path
%%
params.sint=3; % grid search interval in km
params.maxDepth=20; % km
params.minDepth=-1.5; % km
params.maxRadius=45; % km, used to define model search region
params.coasts = true; % plot coast line, requires coast file access
params.wingPlot = true; % make wingplot
params.topo = true; % try to get topo
params.visible = 'off'; % for figures
--
%}
%%
warning('on','all')
tic
% inputFile = '/Users/jpesicek/Dropbox/VDAP/Responses/Agung/mlabloc/locCodeInputs.txt';
[inputs,params] = getInputFiles(inputFile);
[~,~,~] = mkdir(fullfile(inputs.outDir));

diaryFileName = fullfile(inputs.outDir,['/loc_',datestr(now,30),'_diary.txt']);
diary(diaryFileName);
disp(datetime)
disp(inputs)
disp(params)
%%
[qmllist,~] = readtext(inputs.quakeMLfileList);
%%
[sta_zxy, lonlatdep, sname, v_zxy, mstruct] =  mkMod(inputFile);
%%
VpH=sread(fullfile(inputs.outDir,'TTT_Pszyx.H'));
VsH=sread(fullfile(inputs.outDir,'TTT_Sszyx.H'));
xmin = VpH.o(4) ; xmax = VpH.o(4) + VpH.d(4)*VpH.n(4)-VpH.d(4);
ymin = VpH.o(3) ; ymax = VpH.o(3) + VpH.d(3)*VpH.n(3)-VpH.d(3);
zmin = VpH.o(2) ; zmax = VpH.o(2) + VpH.d(2)*VpH.n(2)-VpH.d(2);
inc = params.sint*1000; % meters
if inc ~= VpH.d(2)
    error('FATAL: remake velocity model and TTT?')
end
iix=xmin:inc:xmax; iiy=ymin:inc:ymax; iiz=zmin:inc:zmax;
OTinc = inc/1000/4; % %OT search increment in seconds, based on 4km/s
%%
disp(['km search increment: ',num2str(inc/1000)])
disp(['OT (sec) search increment: ',num2str(OTinc)])
for l = 1:length(qmllist)
    
    quakeMLfile = char(qmllist(l));
    disp(quakeMLfile)
    try
    
    [atObs,I] = getObservedArrivalTimes(quakeMLfile,sname);
    %     OT = min(atObs);
    npicks = sum(~isnan(atObs));
    nsta = length(I);
    mag = []; % does quakeml have mag???
    
    %% find optimal location using brute force
    disp('entering Brute Force Grid Search...')
    [xyzn,OTn,omisfit,data,ib] = BFgridsearch2(iix,iiy,iiz,VpH,VsH,atObs,OTinc);
    
    [F1,F2] = BFgridSearchFigs(iix,iiy,iiz,xyzn,OTn,omisfit,data,ib,sta_zxy(I,:),v_zxy,sname(I),params.visible);
    
    [nlat, nlon] = minvtran(mstruct,xyzn(1),xyzn(2)); % central lat long coordinates
    
    disp(['optimized location (UTM): ',num2str(xyzn)])
    disp(['optimized location: ',num2str([nlat,nlon,xyzn(3)/1000])])
    disp(['New min misfit (seconds) after subsample grid search: ' num2str(omisfit(1))]);
    disp(['Origin time: ',datestr(OTn,'yyyymmdd HH:MM:SS.FFF')])
    disp(['First pick: ',datestr(min(atObs),'yyyymmdd HH:MM:SS.FFF')])

    %% save
    sp1 = strfind(quakeMLfile,'.');
    sp2 = strfind(quakeMLfile,'/');
    figname = quakeMLfile(sp2(end)+1:sp1(end)-1);
    
    savefig(F1,[inputs.outDir,'/',figname,'_1.fig'])
    print(F1,[inputs.outDir,'/',figname,'_1.png'],'-dpng')
    savefig(F2,[inputs.outDir,'/',figname,'_2.fig'])
    print(F2,[inputs.outDir,'/',figname,'_2.png'],'-dpng')
    
    output=sprintf('%s %f %f %f %f %f %d %d',datestr(OTn,'yyyymmddTHHMMSS.FFF'),nlat,nlon,xyzn(3)/1000,omisfit,mag,npicks,nsta);
    outname = [inputs.outDir,'/',figname,'.txt'];
    s6_cellwrite(outname,{output})
    
    %% catalog
    catalog(l).Latitude = nlat;
    catalog(l).Longitude = nlon;
    catalog(l).Depth = xyzn(3)/1000;
    catalog(l).Misfit = omisfit;
    catalog(l).DateTime = datestr(OTn);
    catalog(l).Magnitude = [];
    catalog(l).ID = quakeMLfile;
    catalog(l).npicks = npicks;
    catalog(l).nsta = nsta;
    
    ARCLEN = distance(lonlatdep(:,2),lonlatdep(:,1),nlat,nlon);
    il = ARCLEN==min(ARCLEN);
    catalog(l).minDist = deg2km(ARCLEN(il));

    %TODO: 
%     catalog(l).gap = computeMaxStationGap(nlat,nlon,lonlatdep(:,2),lonlatdep(:,1));
%     catalog(l).xerr
%     catalog(l).yerr
%     catalog(l).zerr
    catch
        warning('problem with pick file, skipping!')
    end
        
end
%%
if numel(catalog)>1
    out2 = struct2table(catalog);
    writetable(out2,fullfile(inputs.outDir,'catalog.csv'))
end

%% plot
if params.wingPlot
    
    [ outer_ann, inner_ann ] = getAnnulusm( inputs.summit(2), inputs.summit(1), params.maxRadius);
    [vinfo] = getVolcanoInfoFromNameOrNum(inputs.str);
    mapdata = prep4WingPlot(vinfo,params,inputs,outer_ann,inner_ann);
    mapdata.sta_lat = lonlatdep(:,2);
    mapdata.sta_lon = lonlatdep(:,1);
    mapdata.sta_elev = lonlatdep(:,3);
    t1a = min(datenum(extractfield(catalog,'DateTime')));
    t2a = max(datenum(extractfield(catalog,'DateTime')));
    params.DepthRange = [params.minDepth params.maxDepth];
    %     [ catalog2, ~, ~ ] = filterAnnulusm( catalog, inputs.summit(2), inputs.summit(1), params.maxRadius);
    fh_wingplot = wingPlot1(vinfo, t1a, t2a, catalog, mapdata, params,1);
    print(fh_wingplot,'-dpng',[inputs.outDir,'/catalog.png'])
    %     close(fh_wingplot)
end
%%
toc
diary OFF
end