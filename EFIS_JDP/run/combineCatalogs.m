%{

Requires:
readtext, RenameField

THIS IS DEPRECATED!

%}

clear

dmax = 35; % max depth of EQs in output catalog
% read the table
% ddir = '/Users/jpesicek/Dropbox/vdap/EFIS/';
% filename='2281630 _ISC_AK2';

ddir1 = '/Users/jpesicek/dropbox/Research/EFIS/ISC/getISCcatalog';
ddir2 = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/getISCcat2';
filename1='iscCatalogAll2';
filename2='iscCatalogMagLT_3pt5';
filename = 'iscCatalogAll3';

table1 = readtext(fullfile(ddir1,[filename1,'.csv']));
table2 = readtext(fullfile(ddir2,[filename2,'.csv']));

% save the first row as the headers
headers = table2(1,1:11);
headers(9) = {'MagAUTHOR'}; % can't have two fields with same name

% save everything else as the data
data1 = table1(2:end,:); % cut out multiple Mags
data2 = table2(2:end,:); % cut out multiple Mags

catalog1 = cell2struct(data1(:,1:11),headers,2);
% clear table data   
catalog2 = cell2struct(data2(:,1:11),headers,2);

catalog =[catalog1; catalog2];

evids=extractfield(catalog,'EVENTID');
if length(unique(evids))~=length(evids)
    warning('duplicate EVIDS')
end

% save('/Users/jpesicek/Research/Alaska/catsearch.20704.mat','catalog');
save(fullfile(ddir2,[filename,'.mat']),'catalog');
