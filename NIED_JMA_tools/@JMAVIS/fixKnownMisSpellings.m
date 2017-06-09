function obj = fixKnownMisSpellings( obj )
%FIXKNOWNMISSPELLINGS Several volcano names are either mis-spelled or
%inconsistently spelled in JMA files. I have dicsovered theses
%irregularities one-by-one. This script corrects those irregularites.

warning('This function will soon be deprecated.')

for i = 1:numel(obj)
    
    name = strip(obj(i).VN, ' ');
    
    if strcmpi(name, 'Akitakomagatake')
        
        obj(i).VN = upper('Akita-Komagatake');
        
    elseif strcmpi(name, 'Akitayakeyama')
        
         obj(i).VN = upper('Akita-Yakeyama');
        
    elseif strcmpi(name, 'Zao‚šan')
    
         obj(i).VN = upper('Zaozan');
         
    elseif strcmpi(name, 'TAISETUSAN')
         
        obj(i).VN = upper('Taisetsuzan');
        
    elseif strcmpi(name, 'Izu-Tobu Volcanoes') || strcmpi(name, 'Izu-TobuVolcanoes')
        
        obj(i).VN = upper('Izu-Tobu');
        
    elseif strcmpi(name, 'Atosanupri')
        
        obj(i).VN = upper('Atosanupuri');
        
    elseif strcmpi(name, 'Tsurumidake and Garandake')
        
        obj(i).VN = upper('Tsurumidake-Garandake');
    
    else
        
        % do nothing
        
    end
        
end

end