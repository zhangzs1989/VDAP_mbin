function plotFreqFiltRSAM(varargin)

% plot frequency filtered RSAM data

% inputFile = '/Users/jpesicek/Dropbox/VDAP/Responses/Agung/RSAM/rsamInputs.txt';
if nargin == 1
    if exist(varargin{1},'file')
        [inputs,params] = getInputFiles(inputFile);
    else
        error('expected input file')
    end
elseif nargin == 2
    inputs = varargin{1};
    params = varargin{2};
elseif nargin > 2
    error('too many arguments')
end
%%
[CT,~,~,~] = importSwarmStationConfig(inputs.stations);
% CT = CT(1:4); %NOTE: here choose channels to do, or edit station file%%
%%
for i=1:size(params.filters,1)
    fobj(i) = filterobject('b',params.filters(i,:),2);
end
%%
scrsz = get(groot,'ScreenSize');
% scrsz = [1 1 1440 1200];
figure('Position',[scrsz(3)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/1]);hold on
pts = 24*60/params.rsamWindow;
c = get(gca,'colororder');
rc = [0 0.5 0];
%%
endDate = floor(params.endDate);
startDate = params.startDate;
ddir = inputs.outDir;

for k=1:numel(fobj)
    
    %%
    for i=1:numel(CT)
        
        j=0;
        rsam = nan((endDate-startDate+1)*pts,1);
        xdata = nan((endDate-startDate+1)*pts,1);
        
        for day = startDate:endDate
            
            j=j+1;
            str = [datestr(day,'yyyymmdd'),'_',get(CT(i),'station'),'_',get(CT(i),'channel'),'.mat'];
            disp(str)
            
            load(fullfile(ddir,str),'RSAM_OBJ')
            d1 = get(RSAM_OBJ(k),'data');
            
            if length(d1) < pts
                warning('data not right length')
            end
            
            rsam((j-1)*pts+1:(j-1)*pts+pts) = d1;
            xdata((j-1)*pts+1:(j-1)*pts+pts) = get(RSAM_OBJ(k),'timevector');
            ct(j,i) = length(d1);
            
        end
        disp(int2str(length(rsam)))
        rsams(:,i) = rsam;
    end
    ax(k)=subplot(numel(fobj),1,k);
    xdata = datetime(datevec(xdata));
    
    if params.plotRatio
        if numel(CT)>2
            warning('not tested for more than 2 stations')
        end
        % now ratio
        % attempt to clean up bad data
        I = rsams<1;
        rsams(I) = nan;
        rrat = rsams(:,1)./rsams(:,2);
        yyaxis right
        plot(xdata,rrat,'Color',rc)
        ax(k).YColor = rc;
        ylabel(['ratio: ',CT(1).station,'/',CT(2).station],'FontWeight','bold')
        %     Y(k) = prctile(rrat,95);
        %     ylim([0 Y(k)])
        
        yyaxis left
    end
    hold on
    for n=1:length(CT)
        grid on, box on
        plot(xdata,rsams(:,n),'Color',c(n,:),'LineStyle','-')
    end
    ylabel(['RSAM (',num2str(params.rsamWindow/60,'%2.1f'),' hrs)'],'FontWeight','bold')
    bp = (get(fobj(k),'cutoff'));
    title(['Frequency Filtered RSAM: ',num2str(bp(1)),'-',num2str(bp(2)),' Hz'])
    legend(CT.string,'location','northwest')
    ax(k).YColor = 'k';
    
    vrsams = reshape(rsams,numel(rsams),1);
    Y(k) = prctile(vrsams,99.5);
    ylim([0 Y(k)])
end
linkaxes(ax,'x')
% axis tight
zoom('xon')
% xlim([datenum(2017,11,01),now])

% print(gcf,fullfile(ddir,'RSAMs'),'-dpng')
% saveas(gcf,fullfile(ddir,'RSAMs.png'))
hgexport(gcf, fullfile(ddir,'RSAMs.png'),  ...
     hgexport('factorystyle'), 'Format', 'png'); 
