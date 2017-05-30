%% LOG2E(RUPTION)LOG

ELOG = table();
for n = 1:height(LOG)
    
    vname = repmat(LOG(n,:).volcano_name(1), numel(LOG(n,:).DATA.E), 1);
    start = get(LOG(n,:).DATA.E, 'start')';
    stop = get(LOG(n,:).DATA.E, 'stop')';
    duration = (stop - start);
    repose = ([NaN; datenum(start(2:end)) - datenum(stop(1:end-1))]);
    time2nxt = ([datenum(stop(2:end)) - datenum(start(1:end-1)); NaN]);
    
    sanom = struct2table(LOG(n,:).SANOM);
    for i = 1:numel(start)
        prior_sanom(i,:) = {sanom(sanom.start < start(i), :)};
        post_sanom(i,:) = {sanom(sanom.start > stop(i), :)};
    end
    
    elog = table(vname, start, stop, duration, repose, time2nxt, prior_sanom, post_sanom);
    ELOG = [ELOG; elog]; 
    clear sanom prior_sanom post_sanom start stop duration repose time2nxt
    disp('Conversion completed')    
    
end