function [countryPolygon,countryName] = getCountryAndPolygon(BUFWIDTH, varargin)

%% get country boundary polygon
warning('on','all')

% BUFWIDTH: buffer in degrees around polygon
shapeFile='/Users/jpesicek/Dropbox/VDAP/EFIS/TM_WORLD_BORDERS_SIMPL-0.3/TM_WORLD_BORDERS_SIMPL-0.3.shp';
S = shaperead(shapeFile);
cnames = extractfield(S,'NAME');
bufres = 13;

if ischar(varargin{1})
    
    countryName = varargin{1};
    I=find(strcmp(cnames,countryName));
    
elseif isnumeric(varargin{1})
    
    if length(varargin{1})~=2
        error('require lat and lon pts for numeric input')
    end
    vlat=varargin{1}(1);
    vlon=varargin{1}(2);
    
    for i = 1:numel(S)
        %         disp(int2str(i))
        lat = S(i).Y;
        lon = S(i).X;
        %         [lat, lon] = bufferm(lat, lon, BUFWIDTH,'outPlusInterior',bufres);
        %         figure, plot(lon,lat,'k')
        IN(i) = inpolygon(vlon,vlat,lon,lat);
        %         if IN(i)
        %             disp(cnames(i))
        %         end
    end
    %     disp(cnames(IN))
    
    if sum(IN)==0
        disp('No country found, adding buffer...')
        parfor i = 1:numel(S)
            %             disp(int2str(i))
            lat = S(i).Y;
            lon = S(i).X;
            %             BUFWIDTH = BUFWIDTH + 1;
            [latb, lonb] = bufferm(lat, lon, BUFWIDTH,'outPlusInterior',bufres);
            [latb,lonb] = flatearthpoly(latb,lonb);
            %         figure, plot(lon,lat,'k')
            %         cn = cnames(i);
            IN(i) = inpolygon(vlon,vlat,lonb,latb);
            %             if IN(i)
            %                 disp(cnames(i))
            %             end
        end
        
    end
    
    if sum(IN)>1
        warning('two countries found');
        % now find which is closer.
        disp(cnames(IN))
        d=0;
        for l=1:find(IN)
            d=d+1;
            [arclen(d),az(d)] = distance(vlat,vlon,S(l).LAT,S(l).LON);
        end
        IN = arclen==min(arclen);
        I = IN;
        disp(['closest is',cnames(I)])
    elseif sum(IN)==0
        
        disp('Still no country found, setting country to NaN')
        I=[];
        
    else
        
        I = IN;
        
    end
    
else
    error('input not understood')
end

countryName = cnames(I);
disp(countryName);

CX = S(I).X';
CY = S(I).Y';
% figure, plot(CX,CY);
[LATB, LONB] = bufferm(CY, CX, BUFWIDTH,'outPlusInterior',bufres);
[LATB,LONB] = flatearthpoly(LATB,LONB);
% countryPolygon=[CX, CY];
% LONB(LONB<0) = LONB(LONB<0) + 360;
countryPolygon=[LONB, LATB];
% CX(CX<0) = CX(CX<0) + 360;
% figure, plot(CX,CY,'k',LONB,LATB,'r');

% save([countryName,'Polygon.txt'],'XY','-ascii')

end