function [ObsArrivalTimes,I] = getObservedArrivalTimes(quakeMLfile,stationNames)

    nsta = length(stationNames);
    picksP0 = nan(nsta,1);
    picksS0 = nan(nsta,1);
    %%
    picks = readQuakeML(quakeMLfile);
    
    st = extractfield(picks,'sta');
    [st,I]=sort(st);
    picks = picks(I);
    %%
    pi = find(strcmp(extractfield(picks,'phase'),'P'));
    si = find(strcmp(extractfield(picks,'phase'),'S'));
    
    if isempty(pi)
        warning('no P picks')
    elseif length(pi)>nsta
        warning('too many P picks')
    end
    
    picksP = picks(pi);
    picksS = picks(si);
    atObsP = extractfield(picksP,'dn')';
    Psta = extractfield(picksP,'sta')';
    [~,~,IBp] = intersect(Psta,stationNames);
    try
        picksP0(IBp) = atObsP;
    catch
        disp(unique(st))
        warning('FATAL: missing station in station file?')
    end

    disp([int2str(length(pi)),' P picks read in'])
    disp(stationNames(IBp)')    
    disp([int2str(length(si)),' S picks read in'])
    
    if ~isempty(picksS)
        atObsS = extractfield(picksS,'dn')';
        Ssta = extractfield(picksS,'sta')';
        [~,~,IBs] = intersect(Ssta,stationNames);
        try
            picksS0(IBs) = atObsS;
        catch
            error('FATAL: missing station in station file?')
        end
        disp(stationNames(IBs)')
    else
        IBs = [];
    end
    
    ObsArrivalTimes = [picksP0;picksS0];
    I = union(IBp,IBs); %Index to stations used
end