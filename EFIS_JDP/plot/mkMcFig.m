function H = mkMcFig(McInfo,varargin)

if nargin == 1
    visibility = 'off';
    mags = [];
    dtimes = [];
elseif nargin == 2
    visibility = varargin{1};
    visibility = validatestring(visibility,{'on','off'}, mfilename, 'visibility');
    mags = [];
    dtimes = [];
else
    mags=varargin{1};
    dtimes=varargin{2};
    visibility = varargin{3};
end
dtimes = datetime(datevec(dtimes));

scrsz = [ 1 1 1080 1920];
H=figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/3],'visible',visibility); hold on  
hold on
%% make time vs Mc plot
ISC_McFile = '/Users/jpesicek/Dropbox/Research/efis/ISC/ISC_Mc.csv';
ISC_McInfo = getGlobalISC_McInfo(ISC_McFile);
ISC_Mc = ISC_McInfo.Mc;
% make stairs for plotting
j=1;
for i=1:length(ISC_Mc)
    iscmc(j,1)=ISC_Mc(i,1);
    iscmc(j+1,1)=ISC_Mc(i,2);
    iscmc(j,2) = ISC_Mc(i,3);
    iscmc(j+1,2)= ISC_Mc(i,3);
    j=j+2;
end
plot(datetime(datevec(iscmc(:,1))),iscmc(:,2),'k-','LineWidth',3)
% datetick,
grid on, box on
lh = {'ISC Mc'};

if ~isempty(dtimes)
    plot(dtimes,mags,'k.')
    lh = [lh,'Mags'];
end
Mc = McInfo.McDaily;
plot(datetime(datevec(Mc(:,1))),Mc(:,2),'r-.','LineWidth',2)
lh = [lh,'Volcano Mc'];
try
    Mc = McInfo.McDailySmooth;
    plot(datetime(datevec(Mc(:,1))),Mc(:,2),'b-','LineWidth',3)
    lh = [lh,'Volcano Mc Smooth'];
% catch
%     warning('no smoothed version available')
end

xlabel('Date')
ylabel('Magnitude')
% title(vinfo.name)
legend(lh)
ylim([0 6])
% text(ISC_Mc(1,1),0,['window size = ',int2str(minN),' events'],'verticalalignment','bottom')
% xlim([ISC_Mc(1,1)-365 ISC_Mc(end,2)+365])
xlim([ISC_Mc(1,1)-365 now])

zoom xon
% print(H,'-dpng',fullfile(outDir,[catStr,'_Mc_',fixStringName(vinfo.name)]))
% close(H)

end