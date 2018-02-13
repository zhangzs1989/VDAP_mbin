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
% first window
i=1;
catalog_i = catalog(i:minN);
mags = extractfield(catalog_i,'Magnitude');
dtimes = datenum(extractfield(catalog_i,'DateTime'));
[F, H, Mc1 ] = Gutenberg(mags,0.1,minN,true);
t1 = min(dtimes); t2 = max(dtimes); % time span network catalog near volcano
% skip window if it is less than X years???
% if t2-t1 > 10*365
%     disp('not enough events in 10 yrs, setting Mc=nan')
%     Mc1 = nan;
% end
% Mc{i,1} = datestr(t1,'yyyy/mm/dd HH:MM:SS.FFF');
Mc{i,1} = datestr(datenum(1964,1,1),'yyyy/mm/dd HH:MM:SS.FFF');
Mc{i,2} = datestr(t2,'yyyy/mm/dd HH:MM:SS.FFF');
Mc{i,3} = Mc1;
Mc{i,4} = i;
% Mc(i,5) = (minN);
% Mc(i,6) = t1+(t2-t1)/2;
if any(~isnan(Mc1))
    set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(mags)),' events)'])
    set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
    print(F,'-dpng',fullfile(outDir,['FMD_',catStr,'_',datestr(t1,'yyyymmdd')]))
    close(F)
end
i1=minN+i;

if numel(catalog)>minN+evWinOverlap
    % middle windows
    i2=0;
    while i2<=numel(catalog)-minN
        
        i1 = Mc{i,4} + evWinOverlap;
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
        
        dtimes = datenum(extractfield(catalog_i,'DateTime'));
        t1 = min(dtimes); t2 = max(dtimes); % time span network catalog near volcano
        % skip window if it is less than X years???
%         if t2-t1 > 10*365
%             disp('not enough events in 10 yrs, setting Mc=nan')
%             Mc1 = nan;
%         end

        Mc{i,3} = Mc1;
        Mc{i,1} = datestr(t1,'yyyy/mm/dd HH:MM:SS.FFF');
        Mc{i,2} = datestr(t2,'yyyy/mm/dd HH:MM:SS.FFF');
        Mc{i,4} = (i1);
        %         Mc(i,5) = (i2);
        %         Mc(i,6) = t1+(t2-t1)/2;
        
        if ~isempty(F) %any(~isnan(Mc))
            set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(mags)),' events)'])
            set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
            print(F,'-dpng',fullfile(outDir,['FMD_',catStr,'_',datestr(t1,'yyyymmdd')]))
            close(F)
        end
        
    end
    %     else
    %         i=i+1;
end
%last window: add in extra events at end
catalog_i = catalog(Mc{i,4}:numel(catalog));
mags = extractfield(catalog_i,'Magnitude');

%make b-value plot
[F, H, Mc1 ] = Gutenberg(mags,0.1,minN,true);
% for now just take mean Mc

dtimes = datenum(extractfield(catalog_i,'DateTime'));
t1 = min(dtimes); t2 = floor(now); %max(dtimes); % time span network catalog near volcano
% skip window if it is less than X years???
% if t2-t1 > 10*365
%     disp('not enough events in 10 yrs, setting Mc=nan')
%     Mc1 = nan;
% end
Mc{i,3} = Mc1;
Mc{i,1} = datestr(t1,'yyyy/mm/dd HH:MM:SS.FFF');
Mc{i,2} = datestr(t2,'yyyy/mm/dd HH:MM:SS.FFF');
Mc{i,4} = (i1);
% Mc(i,5) = (numel(catalog));
% Mc(i,6) = t1+(t2-t1)/2;

if any(~isnan(cell2mat(Mc(:,3))))
    set(get(H(1),'title'),'String',[vinfo.name,' Magnitudes (',int2str(length(catalog_i)),' events)'])
    set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
    print(F,'-dpng',fullfile(outDir,['FMD_',catStr,'_',datestr(t1,'yyyymmdd')]))
    close(F)
end

%% convert constant Mc windows to continous record
% interpolate to every day
if size(Mc,1)>=2
    if BE == 1
        tPts =  datenum(Mc(:,1));
        McPts = Mc{:,3};
        tPts2 = min(tPts):max(tPts); tPts2 = tPts2';
        McPts2 = interp1(tPts,McPts,tPts2);
%     elseif BE == 2
%         tPts =  datenum(Mc(:,2));
%         McPts = cell2mat(Mc(:,3));
%         tPts2 = min(tPts):max(tPts); tPts2 = tPts2';
%         McPts2 = interp1(tPts,McPts,tPts2);
    elseif BE == 3
        tPts = [datenum(Mc(:,1)) + (datenum(Mc(:,2))-datenum(Mc(:,1)))/2];
        McPts =[Mc{:,3}];
        tPts2 = min(tPts):max(tPts); tPts2 = tPts2';
        McPts2 = interp1(tPts,McPts,tPts2);

    elseif BE == 4
        
        McPts = cell2mat(Mc(:,3));
        j=1;l=0;
        while j<=2*length(McPts);
            l=l+1;
%             tPts(j+0,1) = datenum(Mc(l,1));
            tPts(j+0,1) = [datenum(Mc(l,1)) + (datenum(Mc(l,2))-datenum(Mc(l,1)))/2];
            tPts(j+1,1) = [datenum(Mc(l,1)) + (datenum(Mc(l,2))-datenum(Mc(l,1)))/2];
%             tPts(j+2,1) = datenum(Mc(l,2));
            tPts(j+1,1) = datenum(Mc(l,2));

            McPts2(j+0,1)=McPts(l);
            McPts2(j+1,1)=McPts(l);
%             McPts2(j+2,1)=McPts(l);
           
            j=j+2;
        end
        [Y,I] = sort(tPts);
        McPts = McPts2(I);
        tPts = Y;
        tPts2 = min(tPts):max(tPts); tPts2 = tPts2';
        try
            McPts2 = interp1(tPts,McPts,tPts2);
        catch
            warning('Mc Interp Failed!')
            McPts2 = McPts;
        end
        
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

else
    tPts2(1) = datenum(Mc(1,1));
    McPts2(1)= (Mc{1,3});
    McDS = [tPts2' McPts2'];
end
%%
cinfo.Mc = Mc(:,1:3);
cinfo.McDaily = [tPts2 McPts2];
cinfo.McDailySmooth = McDS;
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