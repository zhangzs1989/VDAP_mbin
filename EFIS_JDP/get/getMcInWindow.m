function cinfo = getMcInWindow(t1,t2,catalog,minN,outDir,str)

cinfo.Mc = [];
cinfo.McDaily = [];

if isempty(catalog) || numel(catalog) < minN
    % assign default ISC Mc series
    disp('Not enough events to estimate Mc');
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

%% NOTE: TODO: Should convert all mags to same type !!
%% make overall figure
[F, H, Mc1 ] = Gutenberg(mags,0.1,minN,true);
% t1 = min(dtimes); t2 = max(dtimes); % time span network catalog near volcano
if any(~isnan(Mc1))
    set(get(H(1),'title'),'Interpreter','none')
    set(get(H(1),'title'),'String',[str,' Magnitudes (',int2str(length(mags)),' events)'])
    set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
    print(F,'-dpng',fullfile(outDir,['FMD_',str]))
    close(F)
end
nt = floor(t2 - t1);
tPts = t1+1:t2;
McPts = ones(nt,1)*Mc1;
McDaily = [datenum(tPts)' McPts];
cinfo.McDaily = McDaily;
cinfo.Mc = Mc1;


