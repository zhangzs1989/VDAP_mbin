function V = combinevolcano( obj, combine_type )
%COMBINEVOLCANO Combines multiple JMAVCAT objects that are for the same
%volcano into a single JMAVCAT object

    switch upper(combine_type)
        
        case 'VN'
            allvolcs = get(obj, 'VN');
        case 'VID'
            allvolcs = get(obj, 'VID');            
        otherwise
            
    end
    
    vnames = unique(allvolcs);

    for n = 1:numel(vnames)
        
        lgc = ismember(upper(allvolcs), upper(vnames{n}));
        tmp = obj(lgc);
        T = table();
        for i = 1:numel(tmp)
            T = [T; tmp(i).RawCat];
        end
        try
            T = sortrows(T, 'DATETIME');
        catch
        end
        V(n) = tmp(1);
        V(n).RawCat = T;                
    end

end