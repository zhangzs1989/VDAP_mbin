function [xyzn1,OT1,omisfit1,data,ib] = BFgridsearch2(iix,iiy,iiz,VpH,VsH,picks,OTinc)

nsta = VpH.n(1);
npha = nsta*2;

maxtt = max(VpH.data(:));
maxOT = (min(picks));
minOT = datevec(maxOT);
minOT(6) = minOT(6) - maxtt;
minOT = datenum(minOT);
secs = 60*60*24;
% OTinc = 0.25; %sec
%
% %% PARFOR version
simSpace = [length(iiy),length(iix),length(iiz)];
numSims = prod(simSpace);
%
%
OTs = minOT:OTinc/secs:maxOT;
data = nan(numSims,length(OTs));
omisfit = nan(length(OTs),1);
xyzn = nan(length(OTs),3);

for t=1:length(OTs)
    disp([int2str(t),'/',int2str(length(OTs))])
    tOT = OTs(t);
    ttObs = getObsTTs(picks,tOT);
    % ttObs = getObsTTs(picks,OT);
    
    % parfor idx=1:numSims
    parfor idx=1:numSims
        
        [j, i, k] = ind2sub(simSpace, idx);
        
        xyz_trial = [iix(i) iiy(j) iiz(k)];
        ttPre = getPrePicks(VpH,VsH,xyz_trial);
%         ttPre = ttPre - min(ttPre);
        
        resids = (ttObs-ttPre);
        resids = resids(~isnan(resids));
        
        data(idx,t) = sum(abs(resids))/length(resids); %minimize L1 norm
        %       data(idx,t) = sqrt(sum(resids.^2)/length(resids)); %minimize L2 norm
        %       data(idx) = sqrt(sum(resids.^2)); %minimize L2 norm
        
    end
    
    I = find(data(:,t)==min(data(:,t)));
    if length(I)>1
%         disp('more than one minimum')
        [jj, ii, kk] = ind2sub(simSpace, I);
        if abs(diff(jj))>1 || abs(diff(ii))>1 || abs(diff(kk))>1
            warning('more than one minimum (disparate), taking 1st')
        else
            warning('more than one minimum (colocated), taking 1st') 
        end
    end
    
    [r,c,v] = ind2sub(simSpace,I);
    xn = iix(c); yn = iiy(r); zn=iiz(v);
    xyzn(t,:) = ([xn(1) yn(1) zn(1)]);
    omisfit(t) = data(I(1),t);
    
end
ib = find(omisfit==min(omisfit));
if length(ib)>1
    warning('more than one minimum')
    disp('more than one minimum')
end
xyzn1 = xyzn(ib,:);
omisfit1 = omisfit(ib);
OT1=OTs(ib);

end

