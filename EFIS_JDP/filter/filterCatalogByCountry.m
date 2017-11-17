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

I = strcmp(countryName,cname);
if strcmp(inOut,'in')
    catalog = catalog(I);
else
    catalog = catalog(~I);
end    


end
