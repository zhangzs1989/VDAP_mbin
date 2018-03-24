function [newCatalog,H] = mergeTwoCatalogs(catalog1,catalog2,varargin)

% this script assumes that catalog 2 is the preferred catalog,
% and keeps params from cat2 for matches, except where info is missing,
% which is filled in to cat2 solution from cat1 when possible
%%
%%NOTE: this is very slow on large catalogs, need to parallelize TODO

if nargin == 2
    figTF = 'no';
    OTdiff = 16; % these are params that ANSS uses
    DistDiff = 100; % these are params that ANSS uses
elseif nargin ==3
    figTF = varargin{1};
    OTdiff = 16;
    DistDiff = 100;
elseif nargin == 4
    OTdiff = varargin{1};
    DistDiff = varargin{2};
    figTF = varargin{3};
    figTF = validatestring(figTF,{'yes','no','fig'}, mfilename, 'figTF');
else
    error('bad input')
end
figTF = validatestring(figTF,{'yes','no','fig'}, mfilename, 'figTF');

if isempty(catalog2) && isempty(catalog1)
    newCatalog = []; H = [];
    %     warning('catalogs are empty')
    return
end
if isempty(catalog1)
    newCatalog = catalog2;H = [];
    %     warning('catalog1 is empty')
    return
end
if isempty(catalog2)
    newCatalog = catalog1;H = [];
    %     warning('catalog2 is empty')
    return
end

%%
cat1times=datenum(extractfield(catalog1,'DateTime'));
cat1lat=extractfield(catalog1,'Latitude');
cat1lon=extractfield(catalog1,'Longitude');
% cat1dep=extractfield(catalog1,'Depth');
cat1mags = extractfield(catalog1,'Magnitude');

cat2times=datenum(extractfield(catalog2,'DateTime'));
cat2lat=extractfield(catalog2,'Latitude');
cat2lon=extractfield(catalog2,'Longitude');
% cat2dep=extractfield(catalog2,'Depth');
cat2mags = extractfield(catalog2,'Magnitude');

%% loop over events in catalog 1
iii = zeros(numel(catalog1),1);
for i=1:numel(catalog1) %PARFOR approved
    %
    %all events w/i time tolerance
    [mi]= abs(cat1times(i) - cat2times) < datenum(0,0,0,0,0,OTdiff);
    
    %find all events w/i distance tolerance
    [arclen] = distance(catalog1(i).Latitude,catalog1(i).Longitude,cat2lat',cat2lon');
    [ai] = (arclen<km2deg(DistDiff));
    
    % events that match both criteria
    ii = find(mi & ai );
    
    % if more than one match take smallest OT diff
    if ~isempty(ii)
        [~,mii] = min(abs(cat1times(i) - cat2times(ii)));
        iii(i) = ii(mii);
    end
    
    %     if iii(i) %match
    %         disp(['1: ',datestr(catalog1(i).DateTime)])
    %         disp(['2: ',datestr(catalog2(iii(i)).DateTime)])
    %     end
end

%% indices for repeats:
jj = find(iii~=0);
cat1i = jj; %indices of repeats in cat1
cat2i = iii(jj); %indices of repeats in cat2
% disp(['Matches: ',int2str(length(jj))])

%% QC figure  %%SKIP SOME IF TOO MANY??? TODO
if strcmpi(figTF,'yes') || strcmpi(figTF,'fig')
    disp('merge fig...')
    H = figure('visible','off');
    set(H,'Renderer','OpenGL'); %supposed to be faster
    subplot(2,1,1);
    
    imn1 = isnan(cat1mags);
    imn2 = isnan(cat2mags);
    cat1mags(imn1) = floor(min(cat1mags,[],'omitnan'));
    cat2mags(imn2) = floor(min(cat2mags,[],'omitnan'));
    
    %     plot(datetime(datevec(cat1times)),cat1mags,'b.',datetime(datevec(cat2times)),cat2mags,'g.', ...
    %         datetime(datevec(cat1times(cat1i))),cat1mags(cat1i),'ro',datetime(datevec(cat2times(cat2i))),cat2mags(cat2i),'ro'), grid on
    plot(datetime(datevec(cat1times)),cat1mags,'b.',datetime(datevec(cat2times)),cat2mags,'g.')
    hold on, grid on
    X1 = datetime(datevec(cat1times(cat1i(:))))';
    X2 = datetime(datevec(cat2times(cat2i(:))))';
    Y1 = cat1mags(cat1i(:));
    Y2 = cat2mags(cat2i(:));
    plot([X1;X2],[Y1;Y2],'r-') % SUPER SLOW!!
    
    %% TODO: use nans w/i one line instead of segments
%     lx = []; ly = [];
%     ii=0;
%     for i=1:length(X1)
%         
%         lx(i) = X1(i);
%         ly(i) = Y1(i);
%         
%         lx(i+1) = X2(i);
%         ly(i+1) = Y2(i);
%         
%         lx(i+2) = nan;
%         ly(i+2) = nan;
%         
%     end
    %%
    legend('catalog1','catalog2','Duplicates','Location','Best')
    xlabel('Date')
    ylabel('Magnitude')
    title(['Cat1: ',int2str(length(cat1times)),', Cat2: ',int2str(length(cat2times)),', Matches: ',int2str(length(jj))])
    % datetick
    zoom('xon')
    %     ax2 =subplot(3,1,2);
    %     plot(datetime(datevec(cat1times)),ones(length(cat1times),1),'b.',datetime(datevec(cat2times)),ones(length(cat2times),1),'k.',datetime(datevec(cat1times(cat1i))),ones(length(cat1times(cat1i)),1),'bo',datetime(datevec(cat2times(cat2i))),ones(length(cat2times(cat2i)),1),'ko'), grid on
    %     ylim(ax2,[0 2])
    %     linkaxes([ax1 ax2],'x')
    %     xlim([min(cat2times) max(cat2times)])
    
    subplot(2,1,2)
    worldmap([min([cat2lat cat1lat]),max([cat2lat cat1lat])],[min([cat2lon cat1lon]),max([cat2lon cat1lon])])
    load coast
    plotm(lat,long)%, hold on
    plotm(cat2lat,cat2lon,'g.')
    plotm(cat1lat,cat1lon,'b.')
    if ~isempty(cat1i)
        X1 = cat1lat(cat1i(:));
        X2 = cat2lat(cat2i(:));
        Y1 = cat1lon(cat1i(:));
        Y2 = cat2lon(cat2i(:));
        plot([X1;X2],[Y1;Y2],'r-') % SUPER SLOW!!
        %         for i=1:length(cat1i)
        %             plotm([cat1lat(cat1i(i)) cat2lat(cat2i(i))],[cat1lon(cat1i(i)) cat2lon(cat2i(i))],'r-')
        %         end
        %         plotm(cat1lat(cat1i),cat1lon(cat1i),'ro')
        %         plotm(cat2lat(cat2i),cat2lon(cat2i),'ro');
    end
    
    zoom('on')
    disp('...done')
else
    H = [];
end
%% now what to do with the repeat?
% do local events have magnitudes?  Some don't, take global mag
im2 = find(isnan(cat2mags(cat2i)));

% do global events have mags?
im1 = find(isnan(cat1mags(cat1i)), 1);
if ~isempty(im1)
    error('Global cat has NaN magnitudes, abort')
end
% replace local repeats with no mag with global mags
for i=1:length(im2)
    catalog2(cat2i(im2(i))).Magnitude = catalog1(cat1i(i)).Magnitude;
end
%%
%give merged resulting catalog all fields from both, RIGHT? NOT SURE, maybe
%not
c1fns = fieldnames(catalog1);
c2fns = fieldnames(catalog2);
c3fns = unique([c1fns;c2fns]);
cat3len = numel(catalog1)+numel(catalog2)-numel(jj);

% fill in cat1 global values
for i=1:numel(catalog1) %use parfor if you want
    
    %here give empty as default for all fields
    for j=1:numel(c3fns)
        catalog3(i).(char(c3fns(j))) = [];
    end
    
    %fill in fields from cat1
    for j=1:numel(c1fns)
        catalog3(i).(char(c1fns(j))) = catalog1(i).(char(c1fns(j)));
    end
end

% make change to matches in cat1 from cat2, replace cat2 with cat1 for
% matches
for i=1:numel(jj)
    
    i1 = cat1i(i);
    i2 = cat2i(i);
    for j=1:numel(c2fns)
        catalog3(i1).(char(c2fns(j))) = catalog2(i2).(char(c2fns(j)));
    end
    
end

% remove repeats from local, cat2 since you already used them
ic = zeros(numel(catalog2),1);
for i=1:numel(cat2i)
    ic(cat2i(i)) = 1;
end
catalog2 = catalog2(logical(~ic));

% add remaining local eqs from cat2 that you haven't included yet
ii=0;
for i=numel(catalog3)+1:cat3len
    
    % add default empties for all fields
    for j=1:numel(c3fns)
        catalog3(i).(char(c3fns(j))) = [];
    end
    
    % add cat2 fields for cat2 events
    ii=ii+1;
    for j=1:numel(c2fns)
        catalog3(i).(char(c2fns(j))) = catalog2(ii).(char(c2fns(j)));
    end
end

%% SORT by time
dts3 = datenum(extractfield(catalog3,'DateTime'));
[~,ID] = sort(dts3);
catalog3 = catalog3(ID);

% check for dups
% [ percentDuplicates, ~ ] = check4duplicateEvents(catalog3);
% if percentDuplicates > 0
%     error('Duplicates exist')
% end
if numel(catalog3)>1
    catalog3 = rmDuplicateEvents(catalog3,0);
end
newCatalog = catalog3;

end