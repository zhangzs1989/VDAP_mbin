function [eruptionCat,vinfo] = filterEruptions(eruptionCat,volcanoCat,input,params)

%% get unique list of volcano coords
vinfo.Latitude = extractfield(volcanoCat,'Latitude');
vinfo.Longitude = extractfield(volcanoCat,'Longitude');
vinfo.elevs = extractfield(volcanoCat,'Elevation');
vcoords = [vinfo.Latitude' vinfo.Longitude' vinfo.elevs'];
vcoords = unique(vcoords,'rows');
vinfo.Latitude = vcoords(:,1);
vinfo.Longitude = vcoords(:,2);
vinfo.elevs = vcoords(:,3);
% filter volcano list
lon = vinfo.Longitude;
lon(lon<0)=lon(lon<0)+360;
% figure, plot(lon,lat,'.') % should look like an arc

%%
if isfield(input,'polygonFilter')
    
    
    if ischar(params.polygonFilterSwitch)
        
        
        switch params.polygonFilterSwitch
            
            case 'in'
                
                %% spatial filter of eruptions volcanoes
                [eruptionCat,XV,YV] = regionalCatalogFilter(input,eruptionCat,'in');
                volcs=unique(extractfield(eruptionCat,'Volcano'))';
                nvolcs = numel(volcs);
                disp([int2str(nvolcs),' volcanoes w/ eruptions located w/i polygon'])
                IN = inpolygon(lon,vinfo.Latitude,XV,YV);
                IO = IN;
            case 'out'
                
                %% spatial filter of eruptions volcanoes
                [eruptionCat,XV,YV] = regionalCatalogFilter(input,eruptionCat,'out');
                volcs=unique(extractfield(eruptionCat,'Volcano'))';
                nvolcs = numel(volcs);
                disp([int2str(nvolcs),' volcanoes w/ eruptions located OUTSIDE polygon'])
                IN = inpolygon(lon,vinfo.Latitude,XV,YV);
                IO = ~IN;
            otherwise
                
                warning('polygonFilterSwitch not understood, defaulting to IN')
                [eruptionCat,XV,YV] = regionalCatalogFilter(input,eruptionCat,'in');
                volcs=unique(extractfield(eruptionCat,'Volcano'))';
                nvolcs = numel(volcs);
                disp([int2str(nvolcs),' volcanoes w/ eruptions located w/i polygon'])
                IN = inpolygon(lon,vinfo.Latitude,XV,YV);
                IO = IN;
        end
        
    else
        warning('No polygonFilterSwitch defined, defaulting to IN')
        [eruptionCat,XV,YV] = regionalCatalogFilter(input,eruptionCat,'in');
        volcs=unique(extractfield(eruptionCat,'Volcano'))';
        nvolcs = numel(volcs);
        disp([int2str(nvolcs),' volcanoes w/ eruptions located w/i polygon'])
        IN = inpolygon(lon,vinfo.Latitude,XV,YV);
        IO = IN;
        
    end
    
    vinfo.Latitude = vinfo.Latitude(IO);
    vinfo.Longitude = vinfo.Longitude(IO);
    vinfo.elevs = vinfo.elevs(IO);
    %     disp(volcs)
    
else
    disp('No polygon filtering applied')
    
end

%% narrow eruption catalog by year
if isnumeric(params.YearRange)
    t1=datenum(params.YearRange(1),1,1);%+params.daysBeforeEruption;
    t2=datenum(params.YearRange(2)+1,1,1);%-params.daysAfterEruption;
    eruptionCat = temporalCatalogFilter(eruptionCat,t1,t2);
    %     volcs=unique(extractfield(eruptionCat,'Volcano'))'
else
    disp('no temporal filtering of eruptions applied')
end

%% narrow eruption catalog by VEI
eruptionCat = VEIcatalogFilter(eruptionCat,params);
% volcs=unique(extractfield(eruptionCat,'Volcano'))'
%% sort by time?
% sd = extractfield(eruptionCat,'StartDate');
% [~,I] = sort(datenum(sd));
% eruptionCat = eruptionCat(I);
%% sort by volcano
v = extractfield(eruptionCat,'volcano');
[~,I] = sort((v));
eruptionCat = eruptionCat(I);
end
