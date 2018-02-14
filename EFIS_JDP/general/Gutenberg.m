function [F, H, Mc] = Gutenberg(magnitudes,MagInc,minNumEqs,figYN)

warning('on','all')

if length(magnitudes) < minNumEqs
%     warning('not enough events to estimate Mc')
    Mc = NaN;
    F = [];
    H = [];
    return
end

% xmin = min(magnitudes)-1;
xmin = -1;
xmax = max(magnitudes)+1;
X = xmin:MagInc:xmax;

N=hist(magnitudes,X); %integration method, uncorrected magnitude
Ncum=fliplr(cumsum(fliplr(N)));
logNcum = log10(Ncum);
logN = log10(N);
fdiff = log10(diff(cumsum(N))/MagInc);
iMc = (fdiff==max(fdiff));
Mc = X(iMc);
Mc = max(Mc);

if figYN
    ymax=max(logNcum)+1;
    scrsz = get(groot,'ScreenSize');
    % F=figure('visible','on');
    F = figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(3)/2],'visible','off');
    H(1)=subplot(2,1,1);
    bar(X,N), hold on, grid on
    xlim([xmin xmax])
    xlabel('Magnitude'), ylabel('Occurences')
    
    %% Fit Gutenberg-Richter for magnitudes >conf:
    H(2)=subplot(2,1,2); 
    plot(X,logNcum,'ob',X,logN,'*b',X(:,1:length(fdiff)),fdiff,'.k-',[Mc Mc],[0 ymax],'r-');grid on
    text(Mc,ymax,['Mc = ',num2str(Mc)],'verticalAlignment','top')
    xlim([xmin xmax])
    ylim([0 ymax])
    xlabel('Magnitude'), ylabel('LOG10 (Cumulative Occurences)')
    legend({'cumulative','non-cumulative','1st derivative','Mc'})
else
    F = [];
    H = [];
    
end

end