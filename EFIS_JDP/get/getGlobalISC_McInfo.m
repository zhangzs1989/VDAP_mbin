function  ISC_McInfo = getGlobalISC_McInfo(ISC_McFile)


% ISC_McFile = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/ISC_Mc.csv';
ISC_Mc = readtext(ISC_McFile);

% add points for most recent years:
nr = length(ISC_Mc);
ly = cell2mat(ISC_Mc(nr,1));
lyMc = cell2mat(ISC_Mc(nr,2));

% ty = str2num(datestr(now,'yyyy'))-1;
ty = 2016;
for i=1:(ty-ly)
    ISC_Mc(nr+i,1)={ly + i};
    ISC_Mc(nr+i,2)={lyMc};
end
%%
ISC_Mc = cell2mat(ISC_Mc(2:end,:));
d1 = datenum(ISC_Mc(:,1),1,1);
d2 = d1 + 365;
ISC_Mc = [d1, d2, ISC_Mc(:,2)];
% make stairs for plotting
% j=1;
% for i=1:length(ISC_Mc)
%     iscmc(j,1)=ISC_Mc(i,1);
%     iscmc(j+1,1)=ISC_Mc(i,2);
%     iscmc(j,2) = ISC_Mc(i,3);
%     iscmc(j+1,2)= ISC_Mc(i,3);
%     j=j+2;
% end
Mc = ISC_Mc;
tPts = [Mc(1,1);Mc(:,1) + (Mc(:,2)-Mc(:,1))/2;Mc(end,2)];
McPts =[Mc(1,3);Mc(:,3);Mc(end,3)];
tPts2 = min(tPts):max(tPts);
McPts2 = interp1(tPts,McPts,tPts2);

ISC_McInfo.McDaily = [tPts2',McPts2'];

% timeIntDays = 1;
% timeline=d1(1):timeIntDays:datenum(date);
% ISCMcI = interp1([ISC_Mc(1,1); ISC_Mc(:,2)],[ISC_Mc(1,3);ISC_Mc(:,3)],timeline);

ISC_McInfo.Mc = ISC_Mc;
% ISC_McInfo.DailyMc = [timeline',ISCMcI'];
ISC_McInfo.McMax = max(ISC_Mc(:,3));
ISC_McInfo.McMean= mean(ISC_Mc(:,3));
ISC_McInfo.McMedian=median(ISC_Mc(:,3));
ISC_McInfo.McMinEV = [];

end