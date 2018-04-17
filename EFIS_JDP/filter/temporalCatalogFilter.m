function eruptionCat = temporalCatalogFilter(eruptionCat,t1,t2)

yr = (extractfield(eruptionCat,'StartDate'));
yr = str2num(datestr(datenum(yr),'yyyy'));

I = (datenum(yr,1,1) >= t1 & datenum(yr,1,1) < t2);

% I = logical([1;I]);
eruptionCat = eruptionCat(I,:);
disp([int2str(sum(I)),' eruptions between ',datestr(t1),' and ',datestr(t2),' '])
% unique(extractfield(eruptionCat,'Volcano'))'


end