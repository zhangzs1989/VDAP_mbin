function [catalog,XV,YV]= regionalCatalogFilter(input,catalog,params)

% reads a polygon coord file and filters out points outside/inside
% can read eruption or event catalog, only acts on 'Latitude' and
% 'Longitude' fields
warning('on','all')

% now can input a country name instead to get polygon automatically

if isfield(input,'polygonFilter')
    
    if exist(input.polygonFilter,'file')
        
        poly=input.polygonFilter;
        polyPts = dlmread(poly);
        
    elseif ischar(input.polygonFilter)
        
        disp(['getting polygon for country: ',input.polygonFilter])
        
        if ~isfield(params,'polygonBuffer')
            warning('No buffer width specified, using default of 0.1 degree')
            params.polygonBuffer = 0.1;
        end
        [poly,~]= getCountryAndPolygon(params.polygonBuffer,input.polygonFilter);
        polyPts = poly;
        
    else
        error('BAD input polygon param')
    end
    
    XV = polyPts(:,1);
%     XV(XV<0) = XV(XV<0) + 360;
    YV = polyPts(:,2);
    
    lat = extractfield(catalog, 'Latitude');
    lon = extractfield(catalog, 'Longitude');
    
%     lon(lon<0)=lon(lon<0)+360;
    % figure, plot(lon,lat,'.',poly(:,1),poly(:,2),'r') % should look like an arc
    IN = inpolygon(lon,lat,XV,YV);

    figure,worldmap world
    load coastlines
    plotm(coastlat,coastlon)
    plotm(lat,lon,'k.')
    plotm(YV,XV,'m')
    if sum(IN)~=0
        plotm(lat(IN),lon(IN),'ro')
    end
    
    if isfield(params,'polygonFilterSwitch') && ischar(params.polygonFilterSwitch)
        
        switch params.polygonFilterSwitch
            
            case 'in'
                
                disp([int2str(sum(IN)),' points located w/i polygon'])
                
                catalog = catalog(IN); % AK specific
                
            case 'out'
                
                disp([int2str(sum(~IN)),' points located outside polygon'])
                
                catalog = catalog(~IN); % AK specific
                
            otherwise
                
                error('did not understand your input.')
                
        end
        
    else
        warning('no polygon IN/OUT switch specified, assuming IN')
        disp([int2str(sum(IN)),' points located w/i polygon'])
        catalog = catalog(IN); % AK specific
        
    end
    
    
else
    disp('No polygon filtering applied')
    XV = [];
    YV = [];
end

end