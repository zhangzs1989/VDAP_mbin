function     [vinfo] = getVolcanoInfoFromNameOrNum(argin,varargin)

if nargin == 2
    volcanoCat = varargin{1};
    % this can be a volcanoCat or a location of a volcanoCat
    if ~isstruct(volcanoCat)
        if ~exist(volcanoCat,'file')
            error('argument not understood')
        else
            load(volcanoCat);
            
        end
    end
    
else
    volcanoCat='/Users/jpesicek/Dropbox/Research/EFIS/GVP/GVP_volcanoes_v2.mat';
    load(volcanoCat);
end

if ischar(argin)  % it is a name
    
    vname = argin;
    ii = find(strcmp(fixStringName(extractfield(volcanoCat,'Volcano')),vname));
    if length(ii)>1
        error('name is not unique')
    end
    
elseif isnumeric(argin) % it is a Vnum ID
    
    Vnum = argin;
    ii = find(extractfield(volcanoCat,'Vnum')==Vnum);
    
else
    error('unexpected format')
end

vinfo = getVolcanoInfo(volcanoCat,[],ii);

