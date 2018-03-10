function [windows,chPts] = getMcWindows(t1,t2,mags,einfo,dayInc,nMaxChPts,dtimes,winOpt,evWin,evWinOverlap)

evWin = validatestring(evWin,{'year','month','week','day'}, mfilename, 'evWin');
winOpt = validatestring(winOpt,{'constantEventNumber','constantTimeWindow'});

dn2dt = datetime(datevec(dtimes));

if strcmpi('constantTimeWindow',winOpt)
    
    nwins = between(t1,t2);
    L = calendarDuration(nwins);
    Ln=split(L,evWin);    % get vector of times to create (ir)regular windows from
    windows = dateshift(t1,'start',evWin,0:Ln); %regular, original
    %% get min mag per day time series
    
    timeline = t1:dayInc:t2;
    tl2 = timeline(2:end);
    for i=1:length(tl2)
        I = dn2dt >= timeline(i) & dn2dt < timeline(i+1);
        if sum(I)==0
            magsPerWinMin(i) = nan;
        else
            magsPerWinMin(i) = min(mags(I),[],'omitnan');
        end
    end
    magsPerWinMin = fillgaps(magsPerWinMin);
    
    %% get change points from min mag per day time series
    try
        [ipt,~] = findchangepts(magsPerWinMin,'MaxNumChanges',nMaxChPts,'Statistic','linear');
        chPts = tl2(ipt);
    catch
        warning('problem finding change points')
        j = []; ipt = []; chPts = [];
    end
    % add eruption times as change points
%     if ~isempty(einfo)
%         eChPts = datetime(extractfield(einfo,'StartDate'));
%         chPts = sort([chPts,eChPts]);
%     end
    
    % now merge regular time samples with change points
    % find closest regular point and swap with change piont
    % this keeps the vector the same length but maybe not best.
    for i=1:numel(chPts)
        
        [~,ii] = min(abs(chPts(i)-windows)); % Y in hours here
        windows(ii) = chPts(i);
%         j(i) = ii;
                    
    end
    
    %% ISSUE: this strategy can be removing change points if there are lots of them, BAD.
    % now find any window boundaries that are too close together and purge
    % one of them
    windowso = windows;
    for i=2:numel(windowso)-1
        
        Y = windowso(i+1)-windowso(i); % Y in hours here

        if days(Y) < evWinOverlap %just do 1 for 1 swap
            
            windowso = [windowso(1:i-2),windows(i+2:end)];

        end
        
    end
    windows = windowso;
    
elseif strcmpi('constantEventNumber',winOpt)
    
    %% allunits here are the time windows
    % if you want to do a constant event number window instead of a semi-constant time window,
    % just precompute time windows here, and replace allunits
    ct = 0; t2s =[];
    while ct+minN < numel(dtimes)
        ct = ct + minN ;
        t2a = round(dtimes(ct));
        t2s = [t2s; t2a];
    end
    windows = [t1;datetime(datevec(t2s));t2];
%     j=[];
%     chPts = j;
end
% chPtsI = j;

end