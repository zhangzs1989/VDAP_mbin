function V = combinevolcano( obj )
%COMBINEVOLCANO Combines multiple JMAVEQ objects that are for the same
%volcano into a single JMAVEQ object

    allnames = get(obj, 'VN');
    vnames = unique(allnames);

    for n = 1:numel(vnames)
        
        lgc = ismember(allnames, vnames{n});
        tmp = obj(lgc);
        T = table();
        for i = 1:numel(tmp)
            T = [T; tmp(i).C];
        end
        try
            T = sortrows(T, 'DateTime');
        catch
        end
        V(n) = tmp(1);
        V(n).C = T;                
    end

end

