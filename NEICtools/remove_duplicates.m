function T = remove_duplicates( T )
%REMOVE_DUPLICATES Removes duplicate detections from a table of detections
%producted by the NEIC Subspace Detector
% Assumes that duplicates have exact same value for 'dn1'
% Following this assumption, this script will sort all entries by 'dn1'. It
% then finds duplicates by cycling over the data and comparing each event to
% the last event that wasn't a duplicate.

T = sorttable(T, 'dn1');
keepidx = [1]; % initialize index of entries to keep

last_event.date = T{1, 'dn1'};
last_event.mag = T{1, 'mag'};
for n = 2:numel(T.dn1)
    
    if ~(last_event.date == T{n-1, 'dn1'})
        
        keepidx = [keepidx n];
        last_event.date = T{n, 'dn1'};
        last_event.mag = T{n, 'mag'};

    end

end

T = T(keepidx, :);

end

