function catalog = coords2cat(varargin)

if nargin == 1
    lon = varargin{1}(:,1);
    lat = varargin{1}(:,2);
    dep = varargin{1}(:,3);
elseif nargin == 3
    lon = varargin{1};
    lat = varargin{2};
    dep = varargin{3};
elseif nargin == 2
    lon = varargin{1}(:,1);
    lat = varargin{1}(:,2);
    dep = varargin{1}(:,3);
    ID = varargin{2};
    
    for i=1:length(lon)
        catalog(i).ID = char(ID(i));
    end

else
    error('bad inputs')
end

for i=1:length(lon)
    catalog(i).Longitude = lon(i);
    catalog(i).Latitude = lat(i);
    catalog(i).Depth = dep(i);
end

end