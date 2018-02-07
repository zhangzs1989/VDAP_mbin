%{

Requires:
readtext, RenameField

%}

clear

% dmax = 35; % max depth of EQs in output catalog
% read the table
% ddir = '/Users/jpesicek/Dropbox/vdap/EFIS/';
% filename='2281630 _ISC_AK2';

ddir = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/getISCcatalog';
% ddir = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/getISCcat4';
filename='iscCatalogAll6';

disp('reading in table...')
table = readtext(fullfile(ddir,[filename,'.csv']));
disp('table read in')

% save the first row as the headers
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
% deps = extractfield(catalog,'DEPTH');
% I = deps<=dmax;
% catalog = catalog(I);

%match fields to old EFIS catalog format
catalog = RenameField(catalog,{'LAT','LON','DEPTH','MAG'},{'Latitude','Longitude','Depth','Magnitude'});
catalog = rmfield(catalog,{'DATE','TIME'});

% QC it:
elat = extractfield(catalog, 'Latitude');
elong = extractfield(catalog, 'Longitude');
elong(elong<0)=elong(elong<0)+360;
figure, plot(elong,elat,'.') % should look like an arc

catalog(1).DateTime
catalog(end).DateTime

save(fullfile(ddir,[filename,'.mat']),'catalog');
