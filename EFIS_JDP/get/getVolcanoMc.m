function [cinfo] = getVolcanoMc(vinfo,catalog,outDir,minN,catStr,BE,smoothDayFac)
% estimate Mc over time for a volcano
% below params taking from Woessner, Wiemer, Mignan refs
% radius = 900; % km radius from volcano to measure Mc of ISC cat
% maxz = 70; % km depth cut for ISC cat
% spatial filtering occurs before entry
% temporal params
% minN = 500; % event window size needed to measure new Mc, min events needed to estimate Mc

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

evWinOverlap = round(minN/4); % overlap of windows measuring Mc
[~,~,~] = mkdir(outDir);

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
    print(F,'-dpng',fullfile(outDir,[catStr,'_FMD_',fixStringName(vinfo.name)]))
    close(F)
end
%%
% first window
i=1;
catalog_i = catalog(i:minN);
mags = extractfield(catalog_i,'Magnitude');
dtimes = datenum(extractfield(catalog_i,'DateTime'));
[F, H, Mc1 ] = Gutenberg(mags,0.1,minN,true);
t1 = min(dtimes); t2 = max(dtimes); % time span network catalog near volcano
Mc(i,1) = (t1);
Mc(i,2) = (t2);
Mc(i,3) = Mc1;
Mc(i,4) = (i);
% Mc(i,5) = (minN);
% Mc(i,6) = t1+(t2-t1)/2;
if any(~isnan(Mc))
    set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(mags)),' events)'])
    set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
    print(F,'-dpng',fullfile(outDir,[catStr,'_FMD_',datestr(t1,'yyyymmdd')]))
    close(F)
end
i1=minN+i;

if numel(catalog)>minN+evWinOverlap
    % middle windows
    i2=0;
    while i2<=numel(catalog)-minN
        
        i1 = Mc(i,4) + evWinOverlap;
        i = i + 1;
        i2 = i1 +   minN - 1;
        
        catalog_i = catalog(i1:i2);
        mags = extractfield(catalog_i,'Magnitude');
        
        if sum(isnan(mags))==length(mags)
            warning('PROBLEM: Too many Bad magnitudes')
            return
        end
        
        %make b-value plot
        [F, H, Mc1 ] = Gutenberg(mags,0.1,minN,false);
        Mc(i,3) = Mc1;
        
        dtimes = datenum(extractfield(catalog_i,'DateTime'));
        t1 = min(dtimes); t2 = max(dtimes); % time span network catalog near volcano
        Mc(i,1) = (t1);
        Mc(i,2) = (t2);
        Mc(i,4) = (i1);
        %         Mc(i,5) = (i2);
        %         Mc(i,6) = t1+(t2-t1)/2;
        
        if ~isempty(F) %any(~isnan(Mc))
            set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(mags)),' events)'])
            set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
            print(F,'-dpng',fullfile(outDir,[catStr,'_FMD_',datestr(t1,'yyyymmdd')]))
            close(F)
        end
        
    end
    %     else
    %         i=i+1;
end
%last window: add in extra events at end
catalog_i = catalog(Mc(i,4):numel(catalog));
mags = extractfield(catalog_i,'Magnitude');

%make b-value plot
[F, H, Mc1 ] = Gutenberg(mags,0.1,minN,true);
% for now just take mean Mc
Mc(i,3) = Mc1;

dtimes = datenum(extractfield(catalog_i,'DateTime'));
t1 = min(dtimes); t2 = floor(now); %max(dtimes); % time span network catalog near volcano
Mc(i,1) = (t1);
Mc(i,2) = (t2);
Mc(i,4) = (i1);
% Mc(i,5) = (numel(catalog));
% Mc(i,6) = t1+(t2-t1)/2;

if any(~isnan(Mc))
    set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(catalog_i)),' events)'])
    set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
    print(F,'-dpng',fullfile(outDir,[catStr,'_FMD_',datestr(t1,'yyyymmdd')]))
    close(F)
end

%% convert constant Mc windows to continous record
% interpolate to every day
if size(Mc,1)>=2
    if BE == 1
        tPts =  Mc(:,1);
        McPts = Mc(:,3);
        tPts2 = min(tPts):max(tPts); tPts2 = tPts2';
        McPts2 = interp1(tPts,McPts,tPts2);
    elseif BE == 2
        tPts =  Mc(:,2);
        McPts = Mc(:,3);
        tPts2 = min(tPts):max(tPts); tPts2 = tPts2';
        McPts2 = interp1(tPts,McPts,tPts2);
    elseif BE == 3
        tPts = [Mc(:,1) + (Mc(:,2)-Mc(:,1))/2];
        McPts =[Mc(:,3)];
        tPts2 = min(tPts):max(tPts); tPts2 = tPts2';
        McPts2 = interp1(tPts,McPts,tPts2);
    elseif BE == 4
        %         tPts = [Mc(1,1);Mc(:,1) + (Mc(:,2)-Mc(:,1))/2;Mc(end,2)];
        %         McPts =[Mc(1,3);Mc(:,3);Mc(end,3)];
        tPts = [Mc(:,1) + (Mc(:,2)-Mc(:,1))/2;Mc(end,2)];
        McPts =[Mc(:,3);Mc(end,3)];
        tPts2 = min(tPts):max(tPts); tPts2 = tPts2';
        McPts2 = interp1(tPts,McPts,tPts2);
    else
        FullMc = [];
        for i=1:size(Mc,1)-1
            tPts=Mc(i,1):Mc(i+1,1);
            McPts=ones(length(tPts),1)*Mc(i,3);
            iMc = [tPts' McPts];
            FullMc = [FullMc; iMc];
        end
        FullMc(length(FullMc)+1,1)=Mc(end,2);
        FullMc(length(FullMc),2)=Mc(end,3);
        tPts2 = FullMc(:,1);
        McPts2= FullMc(:,2);
    end
    
    %% smoothing!
    try
        [x_smo, S_smo, S_smo_full]=fct_gen_SmoothHann(tPts2,McPts2,smoothDayFac);
        McDS = [tPts2 S_smo_full];
    catch
        warning('smoothing failed')
        McDS = [tPts2 McPts2];
    end
    % fix endpoints
    % S_smo_full(1) = McPts2(1);
    % S_smo_full(end) = McPts2(end);
    %     xi = round((length(tPts2)-length(x_smo))/2);
    %     S_smo_full(1:xi)=McPts2(1:xi);
    %     S_smo_full(end-xi:end) = McPts2(end-xi:end);
    % McDS = [x_smo S_smo];
    % McDS = [x_smo_full S_smo_full];
else
    tPts2(1) = Mc(1,1);
    McPts2(1)= Mc(1,3);
    %     tPts2(2) = Mc(1,1);
    %     McPts2(2)= Mc(1,3);
    McDS = [tPts2' McPts2'];
end
%%
cinfo.Mc = Mc(:,1:3);
cinfo.McDaily = [tPts2 McPts2];
cinfo.McDailySmooth = McDS;
cinfo.McMax = max(Mc(:,3));
cinfo.McMean = mean(Mc(:,3));
cinfo.McMedian = median(Mc(:,3));
cinfo.McMinEv = minN;
cinfo.McMin = min(Mc(:,3));
% disp(['Max Mc: ',num2str(cinfo.McMax)])

try
    cinfo.MagAuthors = unique(extractfield(catalog,'MagAUTHOR'));
catch
    try
        cinfo.MagAuthors = unique(extractfield(catalog,'AUTHOR'));
    end
end

% %% make time vs Mc plot
% mags = extractfield(catalog,'Magnitude');
% dtimes = datenum(extractfield(catalog,'DateTime'));
% H = mkMcFig(cinfo,mags,dtimes,'off');
% set(get(H(1).Children(2),'title'),'String',[vinfo.name,', ',vinfo.country,'  (',int2str(length(mags)),' events, window = ',int2str(minN),' events, smoothing = ',num2str(smoothDayFac/365),' yrs)'])
% 
% print(H,'-dpng',fullfile(outDir,[catStr,'_Mc_',fixStringName(vinfo.name)]))
% close(H)

end