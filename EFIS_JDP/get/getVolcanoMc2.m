function [cinfo] = getVolcanoMc2(vinfo,catalog,outDir,params,catStr)

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

evWin = validatestring(evWin,{'year','month','week','day'}, mfilename, 'evWin');
winOpt = validatestring(winOpt,{'constantEventNumber','constantTimeWindow'});

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
maxdt = datetime(max(datevec(dtimes)));

t1o=datetime(1964,1,1);
t1 = max([mindt,t1o]);
t2=dateshift(datetime('today'),'start','year');
I = dtimes >= datenum(t1) & dtimes < datenum(t2);
mags = mags(I);
dtimes = dtimes(I);
dn2dt = datetime(datevec(dtimes));

if strcmpi('constantTimeWindow',winOpt)
    
    nwins = between(t1,t2);
    L = calendarDuration(nwins);
    Ln=split(L,evWin);    % get vector of times to create (ir)regular windows from
    allunits = dateshift(t1,'start',evWin,0:Ln); %regular, original
    %% get min mag per day time series
    dayInc=7; %days
    nMaxChPts=5;
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
    [ipt,res] = findchangepts(magsPerWinMin,'MaxNumChanges',nMaxChPts,'Statistic','linear');
    cinfo.McChangePts = tl2(ipt);
    
    % now merge regular time samples with change points
    for i=1:numel(ipt)
        [td,ii] = min(abs(tl2(ipt(i))-allunits));
        allunits(ii) = tl2(ipt(i));
        j(i) = ii;
    end
    
elseif strcmpi('constantEventNumber',winOpt)
    
    %% allunits here are the time windows
    % if you want to do a constant event number window instead of a semi-constant time window,
    % just precompute time windows here, and replace allunits
    ct = 0; t2s =[];
    while ct+minN < numel(dtimes)
        ct = ct + minN ;
        t2a = dtimes(ct);
        t2s = [t2s; t2a];
    end
    allunits = [t1;datetime(datevec(t2s));t2];
    j=[];
    cinfo.McChangePts = j;
end


%%
for i=1:length(allunits)-1
    
    % t1 and t2 of year of interes
    iunit1 = allunits(i);
    iunit2 = allunits(i+1);
    %     disp([iunit1 iunit2])
    %     mpt = datetime(datevec(datenum(iunit1)+(datenum(iunit2)-datenum(iunit1))/2));
    
    %     % find neighboring closets nearYrs on either side
    %     dts = split(between(allunits,mpt),'year');
    if any(i==j)
        %no overlap
        t1a = datenum(iunit1) - evWinOverlap;
        t2a = datenum(iunit2);
    elseif any(i==j+1)
        t1a = datenum(iunit1);
        t2a = datenum(iunit2) + evWinOverlap;
    else
        % overlap
        t1a = datenum(iunit1) - evWinOverlap;
        t2a = datenum(iunit2) + evWinOverlap;
    end
    %     disp(datestr(t1a))
    %     disp(datestr(t2a))
    
    % now get Mc for t1-t2
    I = dtimes >= t1a & dtimes < t2a;
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
        set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(mags)),' events)'])
        set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
        print(F,'-dpng',fullfile(outDir,['FMD_',catStr,'_',datestr(t1,'yyyymmdd')]))
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
%%
cinfo.Mc = Mc(:,1:4);
cinfo.McDaily = [datenum(tPts2) McPts2];
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