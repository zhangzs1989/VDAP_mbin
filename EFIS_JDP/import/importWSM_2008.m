clear

ddir = '/Users/jpesicek/Dropbox/Research/s6/';
filename='wsm2008_smoothed';

% wsm = readtext('/Users/jpesicek/Dropbox/Research/s6/wsm2008.csv',';');

% Heidbach, O., M. Tingay, A. Barth, J. Reinecker, D. Kurfeß, and B. Müller,
% 2010, Global crustal stress pattern based on the World Stress Map data-
% base release 2008: Tectonophysics, 482,3 ? 15, doi:10.1016/j.tecto.2009.07.023.

[table, result]= readtext(fullfile(ddir,[filename,'.csv']),';'); %  FILE

% save the first row as the headers
headers1 = table(1,:);

% save everything else as the data
data = table(2:end,:); % cut out multiple Mags

wsm = cell2struct(data,headers1,2);
clear table data   

% %match fields to old EFIS catalog format
wsm = RenameField(wsm,{'lat','long'},{'Latitude','Longitude'});
% wsm = rmfield(wsm,{'MAG_INT_S1','MAG_INT_S1','MAG_INT_S3'});
% wsm = rmfield(wsm,{'SLOPES1','SLOPES2','SLOPES3','PORE_MAGIN','PORE_SLOPE'});

% QC it:
elat = extractfield(wsm, 'Latitude');
elong = extractfield(wsm, 'Longitude');
elong(elong<0)=elong(elong<0)+360;
figure, plot(elong,elat,'.') % should look like an arc

save(fullfile(ddir,[filename,'.mat']),'wsm');
