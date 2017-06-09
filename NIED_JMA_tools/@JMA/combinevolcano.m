function V = combinevolcano( obj )
%COMBINEVOLCANO Combines multiple JMA objects that are for the same
%volcano into a single JMA object

error(' ')

    allnames = get(obj, 'VN');
    vnames = unique(allnames);

    for n = 1:numel(vnames)
        
        lgc = ismember(allnames, vnames{n});
        tmp = obj(lgc);
        
        V(n) = JMA;
        for i = 1:numel(tmp)
                        
            
        end
        
        
        
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