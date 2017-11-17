function  catalog = import1ISCfile(ofile)

catalog = [];
s=dir(ofile);
if s.bytes == 0
    warning('catalog empty')
    return
end

table = readtext(ofile);
headers1 = table(1,1:11);
headers1(9) = {'MagAUTHOR'}; % can't have two fields with same name

% save everything else as the data
data = table(2:end,:); % cut out multiple Mags

catalog = cell2struct(data(:,1:11),headers1,2);
% clear table data   

% now convert to datenum
dates = (extractfield(catalog,'DATE'));
times = (extractfield(catalog,'TIME'));

for i=1:length(times)
    catalog(i).DateTime = datestr(datenum([cell2mat(dates(i)),' ',cell2mat(times(i))]),'yyyy/mm/dd HH:MM:SS.FFF');
    if isempty(catalog(i).DEPTH)
        catalog(i).DEPTH = NaN;
    end
end

%match fields to old EFIS catalog format
catalog = RenameField(catalog,{'LAT','LON','DEPTH','MAG'},{'Latitude','Longitude','Depth','Magnitude'});
catalog = rmfield(catalog,{'DATE','TIME'});

% % QC it:
% elat = extractfield(catalog, 'Latitude');
% elong = extractfield(catalog, 'Longitude');
% elong(elong<0)=elong(elong<0)+360;
% figure, plot(elong,elat,'.') % should look like an arc

% catalog(1).DateTime
% catalog(end).DateTime

% save(fullfile(ddir,[filename,'.mat']),'catalog');
% save(outCatName,'catalog');




end