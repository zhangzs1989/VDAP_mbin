function V = combinevolcano( obj, combine_type )
%COMBINEVOLCANO Combines multiple JMAVIS objects that are for the same
%volcano into a single JMAVIS object

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
            T = [T; tmp(i).Data];
        end
        try
            T = sortrows(T, 'DATETIME');
        catch
        end
        V(n) = tmp(1);
        V(n).Data = T;                
    end

end

