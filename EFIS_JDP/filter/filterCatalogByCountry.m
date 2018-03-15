function [catalog]= filterCatalogByCountry(catalog,countryName,varargin)

if nargin == 2
    inOut = 'in';
end    

if nargin == 3
    
    inOut = varargin{1};  
    inOut = validatestring(inOut,{'in','out'}, mfilename, 'inOut');    
end

if ~ischar(countryName)
    warning('no country specified')
    return
end
    
    
cname = extractfield(catalog,'country');

I = strcmpi(countryName,cname) | strcmpi(fixStringName(cname),countryName);
if strcmp(inOut,'in')
    catalog = catalog(I);
else
    catalog = catalog(~I);
end    

[~,I] = sort(extractfield(catalog,'Volcano'));
catalog = catalog(I);

end
