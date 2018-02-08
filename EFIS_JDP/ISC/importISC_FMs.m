%{

Requires:
readtext, RenameField

%}

clear

dmax = 50; % max depth of EQs in output catalog
% read the table
% ddir = '/Users/jpesicek/Dropbox/vdap/EFIS/';
% filename='2281630 _ISC_AK2';

ddir = '/Users/jpesicek/dropbox/Research/EFIS/ISC/getISC_FMs/';
filename='iscFM_All';
    
table = readtext(fullfile(ddir,[filename,'.csv']));

% save the first row as the headers
headers1 = table(1,:);
headers1(9) = {'MagAUTHOR'}; % can't have two fields with same name
headers1(13) = {'EX2'}; % can't have two fields with same name
headers1(23) = {'STRIKE2'}; % can't have two fields with same name
headers1(24) = {'DIP2'}; % can't have two fields with same name
headers1(25) = {'RAKE2'}; % can't have two fields with same name
headers1(26) = {'EX3'}; % can't have two fields with same name

% save everything else as the data
data = table(2:end,:); % cut out multiple Mags

FMcat = cell2struct(data(:,:),headers1,2);
% clear table data   

% now convert to datenum
dates = (extractfield(FMcat,'DATE'));
times = (extractfield(FMcat,'TIME'));

parfor i=1:length(times)
    FMcat(i).DateTime = datestr(datenum([cell2mat(dates(i)),' ',cell2mat(times(i))]),'yyyy/mm/dd HH:MM:SS.FFF');
%     if isempty(catalog(i).DEPTH)
%         catalog(i).DEPTH = NaN;
%     end
end
deps = extractfield(FMcat,'DEPTH');

I = deps<=dmax;
FMcat = FMcat(I);

%match fields to old EFIS catalog format
FMcat = RenameField(FMcat,{'LAT','LON','DEPTH','MAG'},{'Latitude','Longitude','Depth','Magnitude'});
FMcat = rmfield(FMcat,{'DATE','TIME'});


% QC it:
elat = extractfield(FMcat, 'Latitude');
elong = extractfield(FMcat, 'Longitude');
elong(elong<0)=elong(elong<0)+360;
figure, plot(elong,elat,'.') % should look like an arc

FMcat(1).DateTime
FMcat(end).DateTime

% save('/Users/jpesicek/Research/Alaska/catsearch.20704.mat','catalog');
save(fullfile(ddir,[filename,'.mat']),'FMcat');
