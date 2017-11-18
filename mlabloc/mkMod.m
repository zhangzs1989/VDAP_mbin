function [sta_zxy, lonlatdep, sname, v_zxy, mstruct] =  mkMod(inputFile)
% make generic Vp and Vs models based on station coords

[inputs,params] = getInputFiles(inputFile);

xgrid=params.sint*1000;
ygrid=params.sint*1000;
zgrid=params.sint*1000;
% vopt = 'gradient'; % homo or gradient
% inputs.velFile='/opt/swarm-2.8.0/OkmokVelocityModel.txt';
% inputs.summit = [115.508,-8.343,2995];
tOff = 500;

[lonlatdep, sname]= getSwarmStationCoords(inputs.stations);

centerLon = mean([lonlatdep(:,1);inputs.summit(1)]);
centerLat = mean([lonlatdep(:,2);inputs.summit(2)]);
lat = lonlatdep(:,2);
lon = lonlatdep(:,1);

%%
try
    % define utm zone and geoid
    utm_zone = utmzone(centerLat,centerLon);
    % [ellipsoid, estr] = utmgeoid(utm_zone);
    
    % define matlab structure for utm projection system
    mstruct = defaultm('utm');
    mstruct.zone = utm_zone;
    % mstruct.geoid = almanac('earth','geoid','m',estr);
    mstruct = defaultm(utm(mstruct));
    r = max(params.maxRadius)*1000;
catch
    %% Set up projection System: mercator
    error('UTM failed, attempting mercator')
    % define matlab structure for utm projection system
    mstruct = defaultm('mercator');
    mstruct.origin = [centerLat centerLon 0];
    mstruct = defaultm(mstruct);
    r = km2rad(max(params.maxRadius));
end
% project data
[x, y] = mfwdtran(mstruct,lat,lon); % central lat long coordinates
[vx, vy] = mfwdtran(mstruct,inputs.summit(2),inputs.summit(1)); % central lat long coordinates

angle_range = (0:360)*pi/180; % radians

o_x = vx + r*cos(angle_range);
o_y = vy + r*sin(angle_range);

o = [params.minDepth*1000 min(o_x) min(o_y)];
maxx = [params.maxDepth*1000 max(o_x) max(o_y)];
%%
% [Vp, Vs] = mkVelMods(o,maxx,xgrid,ygrid,zgrid,vopt);
[Vp, Vs] = mkVelModsFromFile(o,maxx,xgrid,ygrid,zgrid,inputs.velFile);
print(gcf,fullfile(inputs.outDir,'velMods'),'-dpng')

cd(inputs.outDir)
swrite(Vp,'Vp.H')
str = sprintf('echo label1=z label2=x label3=y >> %s/Vp.H',inputs.outDir);
[status,result] = system(str);disp(result)
swrite(Vs,'Vs.H')
str = sprintf('echo label1=z label2=x label3=y >> %s/Vs.H',inputs.outDir);
[status,result] = system(str);disp(result)

%%
% read in models
disp('reading in velocity models....')
Vpmod = sread('Vp.H');
disp('Vp read in');
Vsmod = sread('Vs.H');
disp('Vs read in');
% get model boundaries
zmin = Vpmod.o(1);
xmin = Vpmod.o(2);
ymin = Vpmod.o(3);
zmax = Vpmod.o(1) + (Vpmod.n(1)-1)*Vpmod.d(1);
xmax = Vpmod.o(2) + (Vpmod.n(2)-1)*Vpmod.d(2);
ymax = Vpmod.o(3) + (Vpmod.n(3)-1)*Vpmod.d(3);

xpts = xmin:Vpmod.d(2):xmax;
ypts = ymin:Vpmod.d(3):ymax;
zpts = zmin:Vpmod.d(1):zmax;
[X,Y,Z] = meshgrid(xpts,ypts,zpts);
%%
% setup geometry figure
figure('visible',params.visible)
plot3(x,y,-lonlatdep(:,3),'kv',vx,vy,inputs.summit(3),'r^'); hold on;
text(x+tOff,y+tOff,-lonlatdep(:,3)+tOff,sname)
plot3(X(:),Y(:),-Z(:),'k+')
[X,Y,Z] = meshgrid(xmin:xmax-xmin:xmax,ymin:ymax-ymin:ymax,zmin:zmax-zmin:zmax);
box = [reshape(X,8,1),reshape(Y,8,1),reshape(Z,8,1)];
plot3(box(:,1),box(:,2),box(:,3)*-1,'m+','MarkerSize',14)
grid on;
axis equal;
xlabel('EASTING')
ylabel('NORTHING')
zlabel('ELEVATION')
legend('stations','Summit','nodes','Model Boundaries','Location','NorthEastOutside')
view(2)
print(fullfile(inputs.outDir,'map'),'-dpng')

%%
sta_zxy = [lonlatdep(:,3),x,y]./1000;
v_zxy = [-inputs.summit(3),vx,vy]./1000;
% save('sta_zxy','sta_zxy')
% save('v_zxy','v_zxy')
mkTTT(sta_zxy,inputs.outDir)