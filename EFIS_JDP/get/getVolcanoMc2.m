function [cinfo] = getVolcanoMc2(vinfo,catalog,outDir,minN,catStr,evWin,evWinOverlap)

warning('on','all')

cinfo.Mc = [];
cinfo.McDaily = [];
cinfo.McDailySmooth = [];
cinfo.McMax = NaN;
cinfo.McMean = NaN;
cinfo.McMedian = NaN;
cinfo.McMinEv = NaN;
cinfo.McMin = NaN;

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

if evWinOverlap < 1
    error('overlap should be integer')
end
if isnumeric(evWin)
    error('expected calendar duration input')
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
maxdt = datetime(max(datevec(dtimes)));

t1o=datetime(1964,1,1);
t1 = max([mindt,t1o]);
t2=dateshift(datetime('today'),'start',evWin);

% t2=datetime(datevec(floor(now)))
nwins = between(t1,t2);
% nwins = calendarDuration(
L = calendarDuration(nwins);
Ln=split(L,evWin);
% nwins = nwins(1);
allunits = dateshift(t1,'start',evWin,0:Ln);
ofac = evWinOverlap + 1 ;
% evWin2 = split(evWin,'year');
dn2dt = datetime(datevec(dtimes));

for i=1:Ln
    
    % t1 and t2 of year of interest
    iunit1 = dateshift(t1,'start',evWin,i-1);
    iunit2 = dateshift(t1,'start',evWin,i-0);
%     disp([iunit1 iunit2])
    mpt = datetime(datevec(datenum(iunit1)+(datenum(iunit2)-datenum(iunit1))/2));
    
    % find neighboring closets nearYrs
    dts = split(between(allunits,mpt),evWin);
    [~,I] = sort(abs(dts));
    ayrs = sort(allunits(I(1:ofac)));
    
    % get t1 and t2 of new window
    t1a = min(ayrs);
    t2a = max(ayrs);
    
    % now get Mc for t1-t2
    I = dn2dt >= t1a & dn2dt < t2a;
    catalog_i = catalog(I);
    
    if numel(catalog_i)>0
        mags = extractfield(catalog_i,'Magnitude');
    else
        mags = [];
    end
%     if sum(isnan(mags))==length(mags)
%         warning('PROBLEM: Too many Bad magnitudes')
%         return
%     end
    
    %make b-value plot
    if i==1 || i==Ln
        [F, H, Mc1 ] = Gutenberg(mags,0.1,minN,true);
    else
        [F, H, Mc1 ] = Gutenberg(mags,0.1,minN,false);
    end
    
%     if isnan(Mc1)
%         % get avg ISC Mc for that year
%     end
    
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
%% convert constant Mc windows to continous record
% interpolate to every day
if size(Mc,1)>=2
    
    McPts = cell2mat(Mc(:,3));
    tPtsA = datenum(Mc(:,1));
    tPtsB = datenum(Mc(:,2));
    tPts = tPtsA + (tPtsB-tPtsA)/2;

    ndays = split(between(t1,t2,'days'),'days');
%     tPts  = allunits(1:end-1);
    tPts2  = dateshift(t1,'start','day',0:ndays);
    McPts2 = interp1(tPts,McPts,datenum(tPts2));

else

    tPts2(1) = datenum(Mc(1,1));
    McPts2(1)= (Mc{1,3});

end
%%
cinfo.Mc = Mc(:,1:4);
cinfo.McDaily = [datenum(tPts2') McPts2'];
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