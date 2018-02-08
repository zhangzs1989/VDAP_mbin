function     einfo = getEruptionInfoFromNameOrNum(argin,varargin)
% NOTE that the Num input must be Vnum, not Volcano_ID or eruption_id

if nargin > 1
    eruptionCat = varargin{1};
    % this can be a volcanoCat or a location of a volcanoCat
    if ~isstruct(eruptionCat)
        if ~exist(eruptionCat,'file')
            error('argument not understood')
        elseif exist(eruptionCat,'file')
            load(eruptionCat);
        end
    end
    sw = 'Volcano';    
else
    eruptionCat='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_eruptions_with_ids_v2.mat';
    load(eruptionCat);
end

if nargin > 2
    sw = varargin{2};
end

if ischar(argin)  % it is a name
    
    vname = argin;
    ii = find(strcmp(fixStringName(extractfield(eruptionCat,'volcano')),vname));
    if isempty(ii)
        error('no eruption for name')
    end
    
elseif isnumeric(argin) % it is a Vnum ID
    
    if strcmpi(sw,'Volcano')
        Vnum = argin;
        ii = find(extractfield(eruptionCat,'Vnum')==Vnum);
    elseif strcmpi(sw,'Eruption')
        eruption_id = argin;
        ii = find(extractfield(eruptionCat,'eruption_id')==eruption_id);
    else
        error('bad input str')
    end
        
end

if isempty(ii)
    einfo = [];
else
    for i=1:length(ii)
        einfo(i) = getEruptionInfo(eruptionCat,ii(i));
    end
end

if ~isempty(einfo)
    sd = datenum(extractfield(einfo,'StartDate'));
    [~,I] = sort(sd);
    einfo = einfo(I);
end

end