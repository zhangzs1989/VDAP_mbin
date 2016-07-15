%%
display('----------------------------------------------------------------')
display('Tutorial for WINGPLOTM')
display(' ')

%%

% Load stub data for this tutorial
load('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/mapping/tutorials/stubmapdata.mat')
load('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/mapping/tutorials/stubeqdata.mat')

% create the axis
ax = usamap(mapdata.RA.LatitudeLimits, mapdata.RA.LongitudeLimits);


% plot some stations
wingplotm(eq.lat, eq.lon, eq.depth, 'xr')
hold on
wingplotm(mapdata.sta_lat, mapdata.sta_lon, mapdata.sta_elev, 'vk', 'MarkerFaceColor', 'k')
wingplotm(mapdata.outer(:,1), mapdata.outer(:,2), 'k', 'LineWidth', 2)
wingplotm(mapdata.inner(:,1), mapdata.inner(:,2), 'k', 'LineWidth', 2)