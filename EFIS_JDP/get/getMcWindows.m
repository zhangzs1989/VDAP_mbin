function [windows,chPts] = getMcWindows(t1,t2,mags,einfo,dayInc,nMaxChPts,dtimes,params)

evWin = params.McTimeWindow;
evWinOverlap = params.smoothDays;
winOpt = params.McType;

evWin = validatestring(evWin,{'year','month','week','day'}, mfilename, 'evWin');
winOpt = validatestring(winOpt,{'constantEventNumber','constantTimeWindow'});

dn2dt = datetime(datevec(dtimes));
VEImin = 3;

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
        chPts = tl2(ipt)';
        chPts = combine2setsOfChPts(chPts,[],evWinOverlap);
    catch
        warning('problem finding change points')
        j = []; ipt = []; chPts = [];
    end
    %     windows = cleanupWindows(windows,chPts,evWinOverlap,evWin);
    
    %% add large eruption times as change points
    if ~isempty(einfo)
        eChPts = datetime(extractfield(einfo,'StartDate'));
        vei = extractfield(einfo,'VEI');
        eChPts = eChPts(vei >= VEImin);
        eChPts = eChPts + 1; %NOTE: to make the Mc change happen the day after the eruption to preserve Mc on eruption day
        chPts = combine2setsOfChPts(eChPts',chPts,evWinOverlap);
    end
    
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

windows = addInChPts2windows(windows,chPts,evWinOverlap,evWin);

end
%%
function chPts = combine2setsOfChPts(chPts1,chPts2,evWinOverlap)

% combines to sets of points removing ones from the second set that are too
% close to any in the first set.
% assumes chPts1 is the preferred one

if ~isempty(chPts2)
    chPts = chPts1;
    for i=1:numel(chPts2)
        
        d = abs(datenum(chPts1)-datenum(chPts2(i)));
        if all(d>evWinOverlap)
            chPts = [chPts; chPts2(i)];
        else
            disp('removed 1 chpt that was too close to another')
        end
        
    end
else
    chPts = [chPts1(1)];
    for i=2:numel(chPts1)
        
        d = abs(datenum(chPts1(i))-datenum(chPts1(i-1)));
        if all(d>evWinOverlap)
            chPts = [chPts; chPts1(i)];
        else
            disp('removed 1 chpt that was too close to another')
        end
        
    end    
end
chPts = sort(chPts);

end
%%
function windows = addInChPts2windows(windows,chPts,evWinOverlap,evWin)

if ~strcmpi('year',evWin)
    error('option not implemented')
end

windows2 = windows';
IK = true(length(windows),1);

for i = 1:numel(chPts)
    
    if chPts(i) < min(windows) && chPts(i) > max(windows)
        error('FATAL')
    end
    
    % find points on each side of chpt
    [~,I] = sort(abs(windows-chPts(i)));
    
    %     chPts(i)
    %     windows(I(1))
    %     windows(I(2))
    
    if days( chPts(i) - windows(I(1)) ) < evWinOverlap
        
        IK(I(1)) = false;
        
    elseif days( windows(I(2)) - chPts(i) ) < evWinOverlap
        
        IK(I(2)) = false;
        
    else % its in b/t, remove both outer points
        
        IK(I(1)) = false;
        IK(I(2)) = false;
        
    end
    
end

windows2 = sort([chPts; windows2(IK)]);
windows = windows2;

end

%     td = years(diff(windowso));
%     is = td < mt - evWinOverlap/d;
%
%     if any(is)
%         error('window creation failed')
%     end

% alltimes = sort([windows';chPts']);
% mt = split(calendarDuration(1,0,0),evWin);
% d = 365;
% % now merge regular time samples with change points
% % find closest regular point and swap with change piont
% % this keeps the vector the same length but maybe not best.
% for i=2:numel(alltimes)
%
%     [~,td(i)] = min(abs(alltimes(i)-alltimes(i-1))); % Y in hours here
% %     windows(ii) = chPts(i);
%     %         j(i) = ii;
%
% end
%
% %% ISSUE: this strategy can be removing change points if there are lots of them, BAD.
% % now find any window boundaries that are too close together and purge
% % one of them
% windowso = windows;
% for i=2:numel(windowso)-1
%
%     Y = windowso(i+1)-windowso(i); % Y in hours here
%
%     if days(Y) < evWinOverlap %just do 1 for 1 swap
%
%         windowso = [windowso(1:i-2),windows(i+2:end)];
%
%     end
%
% end
% windows = windowso;

% % first do a one for one swap of chpts with windows that are close to
% % eachother, not changing overall count:
% %find windows smaller than min and just remove one point
%
% td = years(diff(alltimes));
% is = td >= evWinOverlap/d;
% windowso = windows(logical([1;is]));

% now find places where difference between windows is too small and remove
% one of the points, reducing overall count

%
%     %find windows greater than min but less than unit and remove adjacent
%     %2 points
%     ik = ones(length(windowso),1);
%     for i=2:numel(windowso)
%
%         Y = windowso(i)-windowso(i-1); % Y in hours here
%
%         if days(Y) > evWinOverlap  && days(Y) < d
%
%             ik(i) = true;
%             %             windowso = [windowso(1:i-2),windows(i+2:end)];
%
%
%         end
%
%     end
%