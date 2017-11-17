function [volcanoCat,vinfo] = filterVolcanoes(volcanoCat,input,params)

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
                [volcanoCat,XV,YV] = regionalCatalogFilter(input,volcanoCat,params);
                volcs=unique(extractfield(volcanoCat,'Volcano'))';
                nvolcs = numel(volcs);
                disp([int2str(nvolcs),' volcanoes w/ eruptions located w/i polygon'])
                IN = inpolygon(lon,vinfo.Latitude,XV,YV);
                IO = IN;
            case 'out'
                
                %% spatial filter of eruptions volcanoes
                [volcanoCat,XV,YV] = regionalCatalogFilter(input,volcanoCat,params);
                volcs=unique(extractfield(volcanoCat,'Volcano'))';
                nvolcs = numel(volcs);
                disp([int2str(nvolcs),' volcanoes w/ eruptions located OUTSIDE polygon'])
                IN = inpolygon(lon,vinfo.Latitude,XV,YV);
                IO = ~IN;
            otherwise
                
                error('polygonFilterSwitch not understood')
        end
        
    else
        warning('No polygonFilterSwitch defined, defaulting to IN')
        params.polygonFilterSwitch='in';
        [volcanoCat,XV,YV] = regionalCatalogFilter(input,volcanoCat,params);
        volcs=unique(extractfield(volcanoCat,'Volcano'))';
        nvolcs = numel(volcs);
        disp([int2str(nvolcs),' volcanoes w/ eruptions located w/i polygon'])
        IN = inpolygon(lon,vinfo.Latitude,XV,YV);
        IO = IN;
        
    end
    
    vinfo.Latitude = vinfo.Latitude(IO);
    vinfo.Longitude = vinfo.Longitude(IO);
    vinfo.elevs = vinfo.elevs(IO);
    disp(volcs)
    
else
    disp('No polygon filtering applied')
    
end


end
