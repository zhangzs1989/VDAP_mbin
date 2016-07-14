%{
This function reads in an ANSS catalog from the .csv format and saves it as
a Matlab structure such that each event is its own entry in the structure. 
You don't need to do anything to the csv file. The function will handle the
header row appropriately.


Requires:
readtext()

Extract one field of data - e.g., extract all of the depths as a double
array - from the catalog:
>> Depths = extractfield(catalog, 'Depth');

%}

clear

    % read the table
    
    % these two ANSS catalogs have slightly different areal coverage
% table = readtext('/Volumes/EFIS_seis/ANSScatalog/catsearch.15464');

% to get all of AK Aleutians, you have to do two searches one on each side
% of the meridian, so says ANSS website
table2 = readtext('/Volumes/EFIS_seis/ANSScatalog/new2/catsearch.20743',',');
table1 = readtext('/Volumes/EFIS_seis/ANSScatalog/new2/catsearch.22962',',');

    % save the first row as the headers
headers1 = table1(1,:);
headers2 = table2(1,:);

    % save everything else as the data
data1 = table1(2:end,:);
data2 = table2(2:end,:);

data = [data1; data2];

    % put everything into a Matlab structure
    % You have to know the column names that correspond to the column
    % numbers
    % You have to know how you want to parse each one of these.
catalog = {};
for n = 1:length(data)
    
    catalog(n).DateTime = datestr(data{n,1});
    catalog(n).Latitude = cell2mat(data(n,2));
    catalog(n).Longitude = cell2mat(data(n,3));
    catalog(n).Depth = cell2mat(data(n,4));
    catalog(n).Magnitude = cell2mat(data(n,5));
    catalog(n).MagType = data(n,6);
    catalog(n).NbStations = cell2mat(data(n,7));
    catalog(n).Gap = data(n,8);
    catalog(n).Distance = cell2mat(data(n,9));
    catalog(n).RMS = cell2mat(data(n,10));
    catalog(n).Source = data(n,11);
    catalog(n).EventID = data(n,12);
    
        % replace empty Magnitudes with NaN values
    if isempty(catalog(n).Magnitude); catalog(n).Magnitude = NaN; end;
    
end

% QC it:
elat = extractfield(catalog, 'Latitude');
elong = extractfield(catalog, 'Longitude');
elong(elong<0)=elong(elong<0)+360;
figure, plot(elong,elat,'.') % should look like an arc

% dt = extractfield(catalog.DateTime);
% 
% mindate = datestr(min(datenum(dt)))
% maxdate = datestr(max(datenum(dt)))
catalog(1).DateTime
catalog(end).DateTime

% save('/Users/jpesicek/Research/Alaska/catsearch.20704.mat','catalog');
save('/Volumes/EFIS_seis/ANSScatalog/new2/catsearchV4.mat','catalog');
clear table data n data1 data2 table1 table2