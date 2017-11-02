clear
%%
tic
inputFile = '/Users/jpesicek/Dropbox/VDAP/Responses/Agung/mlabloc/locCodeInputs.txt';
[inputs,params] = getInputFiles(inputFile);
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(fullfile(inputs.outDir));

diaryFileName = fullfile(inputs.outDir,['/loc_',datestr(now,30),'_diary.txt']);
diary(diaryFileName);
disp(datetime)
disp(inputs)
disp(params)
%%
[qmllist,result] = readtext(inputs.quakeMLfileList);
%%
[sta_zxy, lonlatdep, sname, v_zxy, mstruct] =  mkMod(inputFile);
%%
VpH=sread(fullfile(inputs.outDir,'TTT_Pszyx.H'));
VsH=sread(fullfile(inputs.outDir,'TTT_Sszyx.H'));
xmin = VpH.o(4) ; xmax = VpH.o(4) + VpH.d(4)*VpH.n(4)-VpH.d(4);
ymin = VpH.o(3) ; ymax = VpH.o(3) + VpH.d(3)*VpH.n(3)-VpH.d(3);
zmin = VpH.o(2) ; zmax = VpH.o(2) + VpH.d(2)*VpH.n(2)-VpH.d(2);
inc = params.sint;
if params.sint ~= VpH.d(2)
    error('FATAL: remake velocity model and TTT?')
end
iix=xmin:inc:xmax; iiy=ymin:inc:ymax; iiz=zmin:inc:zmax;
OTinc = inc/1000/4; % %OT search increment in seconds, based on 4km/s
tOff = 750;
%%
for l = 1:length(qmllist)

    quakeMLfile = char(qmllist(l));
    disp(quakeMLfile)

    [atObs,I] = getObservedArrivalTimes(quakeMLfile,sname);
%     OT = min(atObs);
    
    %% find optimal location using brute force 
    disp(['km search increment: ',num2str(inc/1000)])
    disp(['OT (sec) search increment: ',num2str(OTinc)])
    
    disp('entering Brute Force Grid Search...')
    [xyzn,OTn,omisfit,fv,F] = BFgridsearch2(iix,iiy,iiz,VpH,VsH,atObs,OTinc);

    [nlat, nlon] = minvtran(mstruct,xyzn(1),xyzn(2)); % central lat long coordinates

    disp(['optimized location (UTM): ',num2str(xyzn)])
    disp(['optimized location: ',num2str([nlat,nlon,xyzn(3)/1000])])
    disp(['New min misfit (seconds) after subsample grid search: ' num2str(omisfit(1))]);
    disp(['Origin time: ',datestr(OTn,'yyyymmdd HH:MM:SS.FFF')])
    disp(['First pick: ',datestr(min(atObs),'yyyymmdd HH:MM:SS.FFF')])
    
    %% plot
    plot3(sta_zxy(I,2)*1000,sta_zxy(I,3)*1000,-sta_zxy(I,1)*1000,'kv','MarkerFaceColor','w','MarkerEdgeColor','k','MarkerSize',8); hold on;grid on;
    text(sta_zxy(I,2)*1000+tOff,sta_zxy(I,3)*1000+tOff,-sta_zxy(I,1)*1000+tOff,sname(I),'BackgroundColor','w')
    plot3(v_zxy(:,2)*1000,v_zxy(:,3)*1000,-v_zxy(:,1)*1000,'w^','MarkerFaceColor','k','MarkerSize',20); hold on;grid on;
    view(2)
    title([datestr(OTn,'yyyymmdd HH:MM:SS.FFF'),', Misfit: ',num2str(omisfit(1),'%3.2f'),' (s)'])

    %% save
    sp1 = strfind(quakeMLfile,'.');
    sp2 = strfind(quakeMLfile,'/');
    figname = quakeMLfile(sp2(end)+1:sp1(end)-1);
    
    savefig(F,[inputs.outDir,'/',figname,'.fig'])
    print(F,[inputs.outDir,'/',figname,'.png'],'-dpng')

    output=sprintf('%s %f %f %f %f',datestr(OTn,'yyyymmddTHHMMSS.FFF'),nlat,nlon,xyzn(3)/1000,omisfit);
    outname = [inputs.outDir,'/',figname,'.txt'];
    s6_cellwrite(outname,{output})
    
end
toc
diary OFF
