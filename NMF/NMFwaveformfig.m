function F = NMFwaveformfig(w1,w2,params)

sr = params.newSampleRate;


datas1 = zeros(numel(w1),params.templateLen*sr);
datas2 = zeros(numel(w2),params.templateLen*sr);

F = figure('visible',params.vis); hold on
count = 0;

for jj = 1:numel(w1.w)
    count = count+1;
    
    wd1 = get(w1.w(count),'DATA');
    wstr1 = [get(w1.w(count),'station'),', ',get(w1.w(count),'channel')];
    datas1(count,1:params.templateLen*sr) = bandpass(wd1,params.flo,params.fhi,1/sr,3);
    plot(1:length(datas1(count,:)),datas1(count,:)./max(datas1(count,:))+count*2,'b')
    
    if ~isempty(w2)
        
        wd2 = get(w2.w(count),'DATA');
        datas2(count,1:params.templateLen*sr) = bandpass(wd2,params.flo,params.fhi,1/sr,3);
        plot(1:length(datas2(count,:)),datas2(count,:)./max(datas2(count,:))+count*2,'r')
        text(0,count*2,num2str(w2.mc(count),'%.2f'),...
            'BackgroundColor','w','EdgeColor','k','HorizontalAlignment','right'); % currently showing max for day, not match. Should update
        
    end
    text(length(datas1(count,:)),count*2,wstr1,...
        'color','k','BackgroundColor','w','interpreter','none','fontsize',9,'EdgeColor','k','HorizontalAlignment','left')
    
end

text(length(datas1(count-1,:)),1,['BP = ',num2str(params.flo),'-',num2str(params.fhi),' Hz'],...
    'HorizontalAlignment','right','VerticalAlignment','bottom') %std of day maxes, not match.  Should update

if ~isempty(w2)
    text(length(datas2(count-1,:)),5,['std = ',num2str(std(w2.mc(count),'omitnan'),'%3.2f')],...
        'HorizontalAlignment','right','VerticalAlignment','top') %std of day maxes, not match.  Should update
    title(['{\color{blue}Template ',int2str(w1.i),'@',datestr(w1.t,'mm/dd/yyyy HH:MM:SS'),',} {\color{red}Match ',int2str(w2.i),'@',datestr(w2.t,'mm/dd/yyyy HH:MM:SS'),'}, CCC: ',num2str(w2.ccc,'%3.1f')])
else
    title(['{\color{blue}Template ',int2str(w1.i),'@',datestr(w1.t,'mm/dd/yyyy HH:MM:SS'),'}'])
end


set(gca,'YTickLabel',[])
set(gca,'YTick',[])

% change x axis from samples to seconds
XTo = get(gca,'XTick');
XTi = round(params.templateLen/length(XTo));
XTn = 0:XTi:params.templateLen;
XTnL= XTn*sr;
set(gca,'XTick',XTnL);
set(gca,'XTickLabel',XTn);
xlabel('Seconds')

box on, grid on
axis tight
%     print([QCdir,filesep,datestr(templtime,30),'_',int2str(quakeID),'w.png'],'-dpng')
if strcmp(params.vis,'off')
    close(gcf)
end


end