function [catalog]= filterCatalogByVnameList(catalog,vnameList,varargin)

if nargin == 2
    inOut = 'in';
    country = 'all';
end

if nargin >= 3
    
    inOut = varargin{1};
    inOut = validatestring(inOut,{'in','out'}, mfilename, 'inOut');
    
    if nargin == 4
        country = varargin{2};
    else
        error('too many inputs')
    end
end

if ~iscell(vnameList) && ~ischar(vnameList)
    warning('bad list')
    return
end
%%
if ~strcmpi(country,'all')
    catalog = filterCatalogByCountry(catalog,country,inOut);
end
vnames = extractfield(catalog,'Volcano');

if ischar(vnameList)
    
    if ~strcmpi(vnameList,'all')
        I = strcmpi(vnameList,vnames);
        if isempty(catalog);error('bad vname');end
    else
%         if strcmpi(country,'all')
            [~,I] = sort(extractfield(catalog,'country'));
%         else
%             I = true(length(vnames),1); % use all
%         end
    end
    
else
    
    [~,~,IB] = intersect(vnameList,vnames);
    I = IB;
    
end

if strcmp(inOut,'in')
    catalog = catalog(I);
else
    catalog = catalog(~I);
end

end
