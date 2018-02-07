clearvars -except catalog

input.catalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/getISCcatalog/iscCatalogAll5wFMs.mat';
input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat';
% input.polygonFilter = 'United States';
outFile = 'iscCatalogAll5wFMsTrim2.mat';
%%
if ~exist('catalog','var')
    disp('loading catalog...')
    load(input.catalog);
    disp('...catalog loaded')
end

load(input.gvp_volcanoes)
%%
[BufLat, BufLon ] = getVolcBuffer(volcanoCat, 1000);
figure, worldmap('world')
load coast
plotm(lat,long,'k')
geoshow(BufLat,BufLon,'DisplayType','polygon','FaceColor','green')
plotm(BufLat,BufLon,'b')

% [BufLat, BufLon] = reducem(BufLat,BufLon);
% BufLon(BufLon<0) = BufLon(BufLon<0) + 360;

elats = extractfield(catalog,'Latitude');
elons = extractfield(catalog,'Longitude');
% elons(elons<0) = elons(elons<0) + 360;

[BufLat,BufLon] = flatearthpoly(BufLat,BufLon);
IN = inpolygon(elats,elons,BufLat,BufLon);

%% plottin is too slow, reduce
rfac=10;
elats2 = elats(1:rfac:end);
elons2 = elons(1:rfac:end);
IN2 = IN(1:rfac:end);
%%
plotm(elats2(IN2),elons2(IN2),'r.') %NOTE: this takes forever!!
plotm(elats2(~IN2),elons2(~IN2),'b.')
print('HoloceneVolcCat','-dpng')
%%
catalogISC = catalog(IN);
%%
[ percentDuplicates, ID ] = check4duplicateEvents(catalogISC);
catalogISC = catalogISC(~ID);
%%
parfor i=1:numel(catalogISC)
    dt = extractfield(catalogISC(i),'DateTime');
    dt = datestr(datenum(dt),'yyyy/mm/dd HH:MM:SS.FFF');
    catalogISC(i).DateTime=dt;
end

save(outFile,'catalogISC');
