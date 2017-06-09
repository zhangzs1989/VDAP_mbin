function obj = rawcat2cat( obj )
%RAWCAT2CAT Converts table of raw data to a catalog with one event per line

for o = 1:numel(obj)
    
    clear RC NO uNO uNOidx
    RC = obj(o).RawCat;
    RC = sortrows(RC, 'DATETIME');
    eid = strcat(string(RC.DATETIME), pad(string(RC.NO),10,'left','0'));
    [uNO, uNOidx, ~] = unique(eid);
    uNOidx = [uNOidx; height(RC)+1];
    C = [];
    
    for i = 1:numel(uNO)
    
        rowidx = uNOidx(i):uNOidx(i+1)-1;
        rc = RC(rowidx, :);
        dt = unique(rc.DATETIME);
        no = unique(rc.NO);
        type = unique(rc.TYPE);
        dur_avg = mean(str2double(rc.DUR), 'omitnan');
        nsta = numel(unique(rc.OPOINT));
        opoints = {''};
        
        if numel(dt)==1 && numel(type)==1
           
            C = [C; table(dt, type, dur_avg, nsta, opoints, ...
                'VariableNames', ...
                {'DATETIME', 'TYPE', 'DUR_AVG', 'NSTA', 'OPOINTS'})];
            
        else
            
            warning('More than one time/type/event_no is given')
            i, rc, rowidx, eid(rowidx,:)
%             pause
            
        end
            
    end
    
    obj(o).CAT = C;
    
end
    
end

