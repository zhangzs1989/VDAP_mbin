function [F1,F2] = BFgridSearchFigs(iix,iiy,iiz,xyzn1,OTn,omisfit1,data,ib,sta_zxy,v_zxy,sname,viz)

tOff = 750;
simSpace = [length(iiy),length(iix),length(iiz)];

%%
[x,y,z] = meshgrid(iix,iiy,iiz);
m = reshape(data(:,ib),simSpace);
m2 = m./omisfit1;
xn1 = xyzn1(1); yn1 = xyzn1(2); zn1 = xyzn1(3);
xslice = xn1;
yslice = yn1;
zslice = zn1;

ci = 5; % percent away from minimum to contour
scrsz = [ 1 1 1080 1920]; 
% scrsz = get(groot,'ScreenSize');
%%
F1 = figure('visible',viz);
hold on, box on, grid on
slice(x,y,-z,m,xslice,yslice,-zslice);
plot3(xn1,yn1,-zn1,'ko','markersize',20,'MarkerFaceColor','m','MarkerEdgeColor','w')
colormap(flipud(jet))
% colormap((jet))
c=colorbar;
c.Label.String = 'Misfit (seconds)';
view(3)
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
axis equal
axis tight

fv = isosurface(x,y,-z,m2,ci);
p = patch(fv);
p.FaceColor = 'none';
p.EdgeColor = 'm';
% title({'Misfit (s)',[int2str(ci),'% of Max contoured']});
view(2)

plot3(sta_zxy(:,2)*1000,sta_zxy(:,3)*1000,-sta_zxy(:,1)*1000,'kv','MarkerFaceColor','w','MarkerEdgeColor','k','MarkerSize',8); hold on;grid on;
text(sta_zxy(:,2)*1000+tOff,sta_zxy(:,3)*1000+tOff,-sta_zxy(:,1)*1000+tOff,sname,'BackgroundColor','none')
plot3(v_zxy(:,2)*1000,v_zxy(:,3)*1000,-v_zxy(:,1)*1000,'w^','MarkerFaceColor','k','MarkerSize',20); hold on;grid on;
title([datestr(OTn,'yyyymmdd HH:MM:SS.FFF'),', Misfit: ',num2str(omisfit1,'%3.2f'),' (s)'])

%%
F2 = figure('Position',[scrsz(3)/1 scrsz(4)/2 scrsz(3)/1 scrsz(3)/1],'visible',viz);
subplot(2,2,1)
hold on, box on, grid on
slice(x,y,-z,m,xslice,yslice,-zslice);
plot3(xn1,yn1,-zn1,'ko','markersize',20,'MarkerFaceColor','m','MarkerEdgeColor','w')
colormap(flipud(jet))
% colormap((jet))
c=colorbar;
c.Label.String = 'Misfit (seconds)';
view(3)
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
axis equal
axis tight

fv = isosurface(x,y,-z,m2,ci);
p = patch(fv);
p.FaceColor = 'none';
p.EdgeColor = 'm';
% title({'Misfit (s)',[int2str(ci),'% of Max contoured']});
view(0,90)
plot3(sta_zxy(:,2)*1000,sta_zxy(:,3)*1000,-sta_zxy(:,1)*1000,'kv','MarkerFaceColor','w','MarkerEdgeColor','k','MarkerSize',8); hold on;grid on;
text(sta_zxy(:,2)*1000+tOff,sta_zxy(:,3)*1000+tOff,-sta_zxy(:,1)*1000+tOff,sname,'BackgroundColor','none')
plot3(v_zxy(:,2)*1000,v_zxy(:,3)*1000,-v_zxy(:,1)*1000,'w^','MarkerFaceColor','k','MarkerSize',10); hold on;grid on;
title([datestr(OTn,'yyyymmdd HH:MM:SS.FFF'),', Misfit: ',num2str(omisfit1,'%3.2f'),' (s)'])

%%
subplot(2,2,2)
hold on, box on, grid on
slice(x,y,-z,m,xslice,yslice,-zslice);
view(90,0)
plot3(xn1,yn1,-zn1,'ko','markersize',20,'MarkerFaceColor','m','MarkerEdgeColor','w')
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
axis equal
axis tight

fv = isosurface(x,y,-z,m2,ci);
p = patch(fv);
p.FaceColor = 'none';
p.EdgeColor = 'm';
title('X-Z');
plot3(sta_zxy(:,2)*1000,sta_zxy(:,3)*1000,-sta_zxy(:,1)*1000,'kv','MarkerFaceColor','w','MarkerEdgeColor','k','MarkerSize',8); hold on;grid on;
text(sta_zxy(:,2)*1000+tOff,sta_zxy(:,3)*1000+tOff,-sta_zxy(:,1)*1000+tOff,sname,'BackgroundColor','none')
plot3(v_zxy(:,2)*1000,v_zxy(:,3)*1000,-v_zxy(:,1)*1000,'w^','MarkerFaceColor','k','MarkerSize',10); hold on;grid on;

%%
subplot(2,2,3)
hold on, box on, grid on
slice(x,y,-z,m,xslice,yslice,-zslice);
view(0,0)
plot3(xn1,yn1,-zn1,'ko','markersize',20,'MarkerFaceColor','m','MarkerEdgeColor','w')
colormap(flipud(jet))
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
axis equal
axis tight

fv = isosurface(x,y,-z,m2,ci);
p = patch(fv);
p.FaceColor = 'none';
p.EdgeColor = 'm';
title('Y-Z');
plot3(sta_zxy(:,2)*1000,sta_zxy(:,3)*1000,-sta_zxy(:,1)*1000,'kv','MarkerFaceColor','w','MarkerEdgeColor','k','MarkerSize',8); hold on;grid on;
text(sta_zxy(:,2)*1000+tOff,sta_zxy(:,3)*1000+tOff,-sta_zxy(:,1)*1000+tOff,sname,'BackgroundColor','none')
plot3(v_zxy(:,2)*1000,v_zxy(:,3)*1000,-v_zxy(:,1)*1000,'w^','MarkerFaceColor','k','MarkerSize',10); hold on;grid on;

%%
subplot(2,2,4)
hold on, box on, grid on
slice(x,y,-z,m,xslice,yslice,-zslice);
view(3)
plot3(xn1,yn1,-zn1,'ko','markersize',20,'MarkerFaceColor','m','MarkerEdgeColor','w')
colormap(flipud(jet))
% colormap((jet))
% c=colorbar;
% c.Label.String = 'Misfit (seconds)';
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
axis equal
axis tight

fv = isosurface(x,y,-z,m2,ci);
p = patch(fv);
p.FaceColor = 'none';
p.EdgeColor = 'm';
title({'Misfit (s)',[int2str(ci),'% of Max contoured']});
plot3(sta_zxy(:,2)*1000,sta_zxy(:,3)*1000,-sta_zxy(:,1)*1000,'kv','MarkerFaceColor','w','MarkerEdgeColor','k','MarkerSize',8); hold on;grid on;
text(sta_zxy(:,2)*1000+tOff,sta_zxy(:,3)*1000+tOff,-sta_zxy(:,1)*1000+tOff,sname,'BackgroundColor','none')
plot3(v_zxy(:,2)*1000,v_zxy(:,3)*1000,-v_zxy(:,1)*1000,'w^','MarkerFaceColor','k','MarkerSize',10); hold on;grid on;

    
end