function prepJiggle4Betas(vinfo,catalog)

catalog_j = prepJiggleCatalog(volcname,jiggle);
if isempty(catalog_j)
    warning(['No triggers in jiggle for volcano: ',volcname])
else
    beta_back_catalog=catalog_j; %already volcano-specific for jiggle
    volc_times = datenum(extractfield(beta_back_catalog,'DateTime'));
%     [baddataRAW,baddata,tb,te] = getNetworkOffDaysFromJiggle(jiggle,volcname,min(volcAV_times),max(volc_times),nDaysQC);
    back_windows = exclusion2testwindows(datenum(beta_back_catalog(1).DateTime), datenum(beta_back_catalog(end).DateTime), eruption_windows); % (f1)
    good_windows = series2period(back_windows, baddata, 1, 'exclude'); % (f2)
    beta_back_catalog = filterTime( beta_back_catalog, good_windows(:,1), good_windows(:,2)); numel(beta_back_catalog) % (f3)
    beta_back_catalog_times = datenum(extractfield(beta_back_catalog, 'DateTime')); % (g)
end

