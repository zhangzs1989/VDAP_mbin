function Mc = grabMcInWindow(t1,t2,varargin)


if nargin == 3
    McFile = varargin{1};
elseif nargin == 4
    vinfo = varargin{1};
    catDir = varargin{2};
    McFile = fullfile(catDir,fixStringName(vinfo.country),fixStringName(vinfo.name),'Mc',['MASTER_McInfo_',int2str(vinfo.Vnum),'.mat']);
else
    error('bad argument')
end


if ~exist(McFile,'file')
    Mc = [];
    warning('Mc file DNE')
    return
end

Mc = load(McFile);
% H = mkMcFig(Mc,'on');

%% antiquated now that McInfo holds daily Mc values
% DayRange = t1:t2;
% % I1 = find(Mc.Mc(:,1) < t2 | Mc.Mc(:,2) > t1); %orig
% I1 = find(Mc.Mc(:,1) <= t2 & Mc.Mc(:,2) > t2);
% I2 = find(Mc.Mc(:,2) >= t1 & Mc.Mc(:,1) < t1); %
% I3 = find(Mc.Mc(:,1) < t1 & Mc.Mc(:,2) > t2);
% I4 = find(Mc.Mc(:,1) >= t1 & Mc.Mc(:,2) <= t2);
% I = sort([I1;I2;I3;I4]);
% if length(unique(I))~=length(I)
%     error('BUG')
% end

%%
I = Mc.McDaily(:,1) > t1 & Mc.McDaily(:,1) <= t2;
if sum(I)>0
    Mc.McDaily = Mc.McDaily(I,1:2);
    Mc.McMax = max(Mc.McDaily(:,2),[],'omitnan');
    Mc.McMedian = median(Mc.McDaily(:,2),'omitnan');
    Mc.McMean = mean(Mc.McDaily(:,2),'omitnan');
    Mc.McMin = min(Mc.McDaily(:,2),[],'omitnan');
else
    Mc.McDaily = nan;
    Mc.McMax = nan;
    Mc.McMedian = nan;
    Mc.McMean = nan;
    Mc.McMin = nan;
end

% % interpolate to every day
% tPts = [Mcs(1,1);Mcs(:,1) + (Mcs(:,2)-Mcs(:,1))/2;Mcs(end,2)];
% McPts =[Mcs(1,3);Mcs(:,3);Mcs(end,3)];

% if t2-t1~=1
%     error('REQUIRES DAILY Mc as input')
% %     McPerDay = interp1(tPts,McPts,DayRange);
% % else
% %     [~,I] = min(abs(Mcs(:,1)-t1));
% %     McPerDay = [Mcs(I,3) Mcs(I,3)];
% end

% Mc = [DayRange' McPerDay'];
end