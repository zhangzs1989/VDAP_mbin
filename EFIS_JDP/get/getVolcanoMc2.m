function [cinfo] = getVolcanoMc2(vinfo,einfo,catalog,outDir,params,catStr)

warning('on','all')

cinfo.Mc = [];
cinfo.McDaily = [];
cinfo.McDailySmooth = [];
cinfo.McMax = NaN;
cinfo.McMean = NaN;
cinfo.McMedian = NaN;
cinfo.McMinEv = NaN;
cinfo.McMin = NaN;

minN = params.McMinN;
evWin = params.McTimeWindow;
evWinOverlap = params.smoothDays;
winOpt = params.McType;

if isempty(catalog) || numel(catalog) < minN
    % assign default ISC Mc series
    warning('Not enough events to estimate Mc');
    return
end

mags = extractfield(catalog,'Magnitude');
ei = isnan(mags);
catalog = catalog(~ei);
mags = mags(~ei);

if isempty(catalog) || numel(catalog) < minN
    % assign default ISC Mc series
    warning('Not enough events to estimate Mc');
    return
end

if sum(~ei)==0
    % assign default ISC Mc series
    warning('Not enough magnitudes to estimate Mc');
    return
end
%%
dtimes = datenum(extractfield(catalog,'DateTime'));
if ~issorted(dtimes)
    [Y,I] = sort(dtimes);
    catalog = catalog(I);
    dtimes = Y;
end
%% NOTE: TODO: Should convert all mags to same type !!
%% make overall figure
[F, H, Mc1 ] = Gutenberg(mags,0.1,minN,true);
t1 = min(dtimes); t2 = max(dtimes); % time span network catalog near volcano
if any(~isnan(Mc1))
    set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(mags)),' events)'])
    set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
    print(F,'-dpng',fullfile(outDir,['FMD_',catStr,'_',fixStringName(vinfo.name)]))
    close(F)
end
%%
% [y,m,d] = split(evWin,{'years','months','days'});
mindt = datetime(min(datevec(dtimes)));
% maxdt = datetime(max(datevec(dtimes)));

t1o=datetime(1964,1,1);
t1 = max([mindt,t1o]);
t2=dateshift(datetime('today'),'start','year');
I = dtimes >= datenum(t1) & dtimes < datenum(t2);
mags = mags(I);
dtimes = dtimes(I);

dayInc=7; %days
nMaxChPts=5;
[allunits,chPts] = getMcWindows(t1,t2,mags,einfo,dayInc,nMaxChPts,dtimes,winOpt,evWin,evWinOverlap);
cinfo.McChangePts = chPts;
%%
for i=1:length(allunits)-1
    
%     minNflag = false;
    % t1 and t2 of year of interes
    iunit1 = allunits(i);
    iunit2 = allunits(i+1);
%     disp([iunit1 iunit2])
%     mpt = datetime(datevec(datenum(iunit1)+(datenum(iunit2)-datenum(iunit1))/2));

    %     % find neighboring closets nearYrs on either side
    %     dts = split(between(allunits,mpt),'year');
    
    t1a = datenum(iunit1) - evWinOverlap;
    t2a = datenum(iunit2) + evWinOverlap;
    
    if any(iunit2==chPts) 
        t2a = datenum(iunit2) ;
    end

    if any(iunit1==chPts)
        t1a = datenum(iunit1) ;
    end
    %     disp([datestr(t1a) datestr(t2a)])
    
    % now get Mc for t1-t2
    I = dtimes >= t1a & dtimes < t2a;
    
%     %Not enough events in year, find nearest N events and use them, but
%     if length(I) < minN && strcmpi(catStr,'LOCAL')
%         % find closest N events
%         [Y,ei] = sort(abs(dtimes-datenum(mpt)));
%         dtimesI = dtimes(ei(1:minN));
%         [C,I,DI] = intersect(dtimes,dtimesI);
%         minNflag=true;
%     end    
    
    catalog_i = catalog(I);
        
    if numel(catalog_i)>0
        mags = extractfield(catalog_i,'Magnitude');
    else
        mags = [];
    end
    
    %make b-value plot
    if i==1 || i==length(allunits)-1
        [F, H, Mc1 ] = Gutenberg(mags,0.1,minN,true);
    else
        [F, H, Mc1 ] = Gutenberg(mags,0.1,minN,false);
    end
    
    Mc{i,1} = datestr(iunit1,'yyyy/mm/dd HH:MM:SS.FFF');
    Mc{i,2} = datestr(iunit2,'yyyy/mm/dd HH:MM:SS.FFF');
    Mc{i,3} = Mc1;
    Mc{i,4} = (length(mags));
    
    if ~isempty(F) %any(~isnan(Mc))
%         if minNflag
%             set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(mags)),' closest events)'])
%         else
            set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(mags)),' events)'])
%         end
        set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1a,23),' to ',datestr(t2a,23)])
        print(F,'-dpng',fullfile(outDir,['FMD_',catStr,'_',datestr(t1a,'yyyymmdd')]))
        close(F)
    end
    
end
%% convert constant Mc windows to continous record. THIS IS IMPORTANT HOW YOU DO THIS! AND NO RIGHT ANSWER
% interpolate to every day?
% use begining, midpoint, end point of constant window for interp?
if size(Mc,1)>=2
    
    tPts = []; McPts = [];
    for i=1:numel(Mc(:,1))
        nt = floor(datenum(Mc{i,2}) - datenum(Mc{i,1}));
        tpts = datenum(Mc{i,1}):datenum(Mc{i,2})-1;
        mpts = ones(nt,1)*Mc{i,3};
        tPts = [tPts; tpts'];
        McPts = [McPts; mpts];
    end
    
    McPts2 = McPts;
    tPts2 = tPts;
    
else
    tPts2(1) = datenum(Mc(1,1));
    McPts2(1)= (Mc{1,3});
end

% fill gaps, but only b/t middle pieces, not start and end
I=find(~isnan(McPts2));
if ~isempty(I)
    i1 = I(1); i2 = I(end);
    McPts2(i1:i2) = fillgaps(McPts2(i1:i2));
end
McDaily = [datenum(tPts2) McPts2];
%%
cinfo.Mc = Mc(:,1:4);
cinfo.McDaily = McDaily;
cinfo.McDailySmooth = [];
cinfo.McMax = max(cell2mat(Mc(:,3)));
cinfo.McMean = mean(cell2mat(Mc(:,3)));
cinfo.McMedian = median(cell2mat(Mc(:,3)));
cinfo.McMinEv = minN;
cinfo.McMin = min(cell2mat(Mc(:,3)));
% disp(['Max Mc: ',num2str(cinfo.McMax)])

try
    cinfo.MagAuthors = unique(extractfield(catalog,'MagAUTHOR'));
catch
    try
        cinfo.MagAuthors = unique(extractfield(catalog,'AUTHOR'));
    end
end

end