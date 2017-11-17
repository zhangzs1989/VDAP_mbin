clear

input.gvp_volcanoes='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat'; % imported via importEruptionCatalog, originally from S. Ogburn
input.gvp_eruptions='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/global8'; % importISCcatalog.m
%%
LocalMcDef = 2;
McRange = 0:6;
inc=7;
%%
load(input.gvp_volcanoes)
% [result,status,probCountries,probVolcanoes] = checkCatalogDBintegrity(input.catalogsDir,volcanoCat);
trange = datenum(1964,1,1):inc:datenum(2017,1,1);
%%
McMin = zeros(numel(volcanoCat),1);
Mc2 = zeros(numel(volcanoCat),length(trange));
for i=1:numel(volcanoCat)
    
    vpath = fullfile(input.catalogsDir,fixStringName(volcanoCat(i).country),fixStringName(volcanoCat(i).Volcano));
    McFile = fullfile(vpath,['Mc/MASTER_McInfo_',int2str(volcanoCat(i).Vnum),'.mat']);
    
    Mc = load(McFile);
    McMin(i) = Mc.McMin;
    
    for j=1:length(trange)
        Mc2(i,j) = Mc.McDaily((j-1)*inc+1,2);
    end
    vinfo = getVolcanoInfo(volcanoCat,[],i);
    lat(i) = vinfo.lat;
    lon(i) = vinfo.lon;
end

I1 = zeros(numel(volcanoCat),length(McRange));
pLocal = zeros(length(McRange),1);
for i=1:length(McRange)
    I1(:,i) = McMin <= McRange(i);
    pLocal(i) = sum(I1(:,i))/size(I1,1);
end
%%
scrsz = get(groot,'ScreenSize');
figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/3],'visible','on');
subplot(2,3,1)
X=categorical(logical(I1(:,McRange == LocalMcDef)));
pie(X);
% c = get(gca,'colororder');
% colormap(c2)
title({['EFIS Local Catalogs (Mc <= ',int2str(LocalMcDef),')'],[int2str(numel(volcanoCat)),' Holocene Volcanoes']});
% legend(ua,'Location','Best')
subplot(2,3,4)
x = McRange;
y = pLocal*100;
plot(x,y,'ob-',[LocalMcDef LocalMcDef],[0 100],'k-'), grid on, box on
ylabel('% with Mc')
xlabel('Mc')
title('EFIS catalog quality')

%% % volcanoes with eruptions since 1964 with Mc
load(input.gvp_eruptions)
[C,IA,IB] = intersect(extractfield(eruptionCat,'Vnum'),extractfield(volcanoCat,'Vnum'));

I2 = I1(IB,:);
pLocal2 = zeros(length(McRange),1);
McMin = McMin(IB);
for i=1:length(McRange)
    I2(:,i) = McMin <= McRange(i);
    pLocal2(i) = sum(I2(:,i))/size(I2,1);
end
%%
subplot(2,3,2)
X=categorical(logical(I2(:,McRange == LocalMcDef)));
pie(X);
% c = get(gca,'colororder');
% colormap(c2)
title({['EFIS Local Catalogs (Mc <= ',int2str(LocalMcDef),')'],[int2str(numel(volcanoCat(IB))),' Volcanoes with Eruptions since 1964']});
% legend(ua,'Location','Best')
subplot(2,3,5)
x = McRange;
y = pLocal2*100;
plot(x,y,'ob-',[LocalMcDef LocalMcDef],[0 100],'k-'), grid on, box on
ylabel('% with Mc')
xlabel('Mc')
title('EFIS catalog quality')

%% % eruptions with local cat
preEruptionDays = 60;
preEruptiveMcs = zeros(numel(eruptionCat),1);
for i=1:numel(eruptionCat)
    
    ii = find(extractfield(volcanoCat,'Vnum')==eruptionCat(i).Vnum);
    vinfo = getVolcanoInfo(volcanoCat,[],ii);
    vpath = fullfile(input.catalogsDir,fixStringName(vinfo.country),fixStringName(vinfo.name));
    McFile = fullfile(vpath,['Mc/MASTER_McInfo_',int2str(vinfo.Vnum),'.mat']);
    
    t1 = datenum(eruptionCat(i).StartDate) - preEruptionDays;
    t2 = datenum(eruptionCat(i).StartDate);
    
    Mcs = grabMcInWindow(t1,t2,McFile);
    preEruptiveMcs(i) = median(Mcs.McDaily(:,2),'omitnan');
    lat2(i) = vinfo.lat;
    lon2(i) = vinfo.lon;
end

I3 = zeros(numel(eruptionCat),length(McRange));
pLocal3 = zeros(length(McRange),1);
for i=1:length(McRange)
    I3(:,i) = preEruptiveMcs <= McRange(i);
    pLocal3(i) = sum(I3(:,i))/size(I3,1);
end

%%
subplot(2,3,3)
X=categorical(logical(I3(:,McRange == LocalMcDef)));
pie(X);
% c = get(gca,'colororder');
% colormap(c2)
title({['Local pre eruptive Catalogs (Mc <= ',int2str(LocalMcDef),')'],[int2str(numel(eruptionCat)),' Eruptions']});
% legend(ua,'Location','Best')
subplot(2,3,6)
x = McRange;
y = pLocal3*100;
plot(x,y,'ob-',[LocalMcDef LocalMcDef],[0 100],'k-'), grid on, box on
ylabel('% with Mc')
xlabel('Mc')
title('EFIS catalog quality')

print(gcf,fullfile(input.catalogsDir,'1_McCatalogStats'),'-dpng');
%%
figure,ax = worldmap('World');
setm(ax, 'Origin', [0 180 0])
land = shaperead('landareas', 'UseGeoCoords', true);
geoshow(ax, land, 'FaceColor', [0.5 0.7 0.5])
l(1)=plotm(lat,lon,'k.');
k = logical(I1(:,3));
l(2)=plotm(lat(k),lon(k),'r^','MarkerFaceColor','r');
title('Holocene Volcanoes')
lh=legend(l,'Active Volcano','Some local data in EFIS');

print([input.catalogsDir,filesep,'3_Map1_'],'-dpng')
savefig([input.catalogsDir,filesep,'3_Map1_'])

figure,ax = worldmap('World');
setm(ax, 'Origin', [0 180 0])
land = shaperead('landareas', 'UseGeoCoords', true);
geoshow(ax, land, 'FaceColor', [0.5 0.7 0.5])
l(1)=plotm(lat(IB),lon(IB),'r.');
k = logical(I3(:,3));
l(2)=plotm(lat2(k),lon2(k),'b^','MarkerFaceColor','b');
title('Eruptions since 1965')
lh=legend(l,'Eruption','Pre-eruptive local data in EFIS');

print([input.catalogsDir,filesep,'3_Map2_'],'-dpng')
savefig([input.catalogsDir,filesep,'3_Map2_'])

%% % time history of Median Mc
x=((trange));
Mc2 = Mc2(:,1:size(trange,2));
y1 = min(Mc2,[],1);
y2 = mean(Mc2,1,'omitnan');
y3 = median(Mc2,1,'omitnan');
y4 = max(Mc2,[],1,'omitnan');
y5 = std(Mc2,1,'omitnan');
%%
iy1 = ~isnan(y1);
iy4= ~isnan(y4);
yy1 = y1(iy1);
yy4 = y4(iy4);
xx1 = x(iy1);
xx4 = x(iy4);
[xx4b,I] = sort(xx4,'descend');
figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/3],'visible','on');
fill([xx1,xx4b],[yy1,yy4(I)],0.9*[1 1 1],'EdgeColor','none');
hold on, grid on, box on
plot(x,y2,'k',x,y3,'b',x,y5,'m','LineWidth',3)
xlabel('Date')
ylabel('Mc')
title('EFIS catalog Mc')
datetick
xlim([trange(1) trange(end)])
ylim([0 5])
legend('Range','Mean','Median','std')%,'location','best')
print(gcf,fullfile(input.catalogsDir,'2_McCatalogTime'),'-dpng');

%%
ISC_McFile = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/ISC_Mc.csv';
ISC_McInfo = getGlobalISC_McInfo(ISC_McFile);

D2 = dir2(fullfile(input.catalogsDir));
D2 = removeHiddenFiles(D2);
I = logical(cell2mat(extractfield(D2,'isdir')));
D2 = D2(I);

%% Individual country figs
for c = 1:numel(D2)
    
    disp(int2str(c))
    dc=fullfile(input.catalogsDir,D2(c).name);
    DC=dir2(dc,'Master_McInfo_*.mat','-r');
    
    figure('visible','off'), hold on, grid on, box on
    h2=plot(ISC_McInfo.McDaily(:,1),ISC_McInfo.McDaily(:,2),'r-','LineWidth',6);
    
    yq=nan(numel(DC),length(trange));
    for v=1:numel(DC)
        McInfo = load(fullfile(dc,DC(v).name));
        x = McInfo.McDaily(:,1);
        y = McInfo.McDaily(:,2);
        if length(x)<2
            continue
        end
        hi = plot(x,y,'linestyle','--','LineWidth',1,'color',[0.5 0.5 0.5]);
        yq(v,:) = interp1(x,y,trange);
        %         subreg{v} = vinfo.subregion;
    end
    hc=plot(trange,median(yq,1,'omitnan'),'linestyle','-','LineWidth',4,'color','b');
    
    datetick
    xlabel('Date')
    ylabel('Mc')
    title([D2(c).name,' Mc'])
    xlim([min(trange) max(trange)])
    ylim([0 6])
    lg = legend([h2(1),hi(1),hc(1)],'ISC Mc','Volcano Mcs','Median Country Mc');
    print(gcf,'-dpng',fullfile(input.catalogsDir,D2(c).name,'1McFig'))
    close(gcf)
    
end
%% Overall 20+ volcano country fig
b=0;lg=[{'ISC'}];
figure('visible','on'), hold on, grid on, box on
h2=plot(ISC_McInfo.McDaily(:,1),ISC_McInfo.McDaily(:,2),'k-','LineWidth',8);
for c = 1:numel(D2)
    
    dc=fullfile(input.catalogsDir,D2(c).name);
    DC=dir2(dc,'Master_McInfo_*.mat','-r');
    
    yq=nan(numel(DC),length(trange));
    if numel(DC) > 20
        b=b+1;
        for v=1:numel(DC)
            McInfo = load(fullfile(dc,DC(v).name));
            x = McInfo.McDaily(:,1);
            y = McInfo.McDaily(:,2);
            if length(x)<2
                continue
            end
            %             hi = plot(x,y,'linestyle','--','LineWidth',1,'color',[0.5 0.5 0.5]);
            yq(v,:) = interp1(x,y,trange);
        end
        lg =[lg, {D2(c).name}];
        %         c = get(gca,'colororder');
        colors = get(gca,'ColorOrder');
        index  = get(gca,'ColorOrderIndex');
        n_colors = size(colors,1);
        if index > n_colors
            index = 1;
        end
        next_color = colors(index,:);
        
        hc(b)=plot(trange,median(yq,1,'omitnan'),'linestyle','-','LineWidth',4,'color',next_color);
    end
    
end
datetick
xlabel('Date')
ylabel('Mc')
title(['EFIS Median Mc for Countries with >20 Volcanoes'])
xlim([min(trange) max(trange)])
ylim([0 6])
lgh = legend(lg,'location','best');
print(gcf,'-depsc2',fullfile(input.catalogsDir,'1McBig'))
close(gcf)
