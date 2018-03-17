function  FMcatalog = import1ISC_MTfile(ofile)

FMcatalog = [];
s=dir(ofile);
if s.bytes == 0 
%     warning('MT catalog empty')
    return
end

table = readtext(ofile);
headers1 = table(1,:);
headers1(9) = {'MagAUTHOR'}; % can't have two fields with same name
headers1(13) = {'EX2'}; % can't have two fields with same name
headers1(23) = {'STRIKE2'}; % can't have two fields with same name
headers1(24) = {'DIP2'}; % can't have two fields with same name
headers1(25) = {'RAKE2'}; % can't have two fields with same name
headers1(26) = {'EX3'}; % can't have two fields with same name

% save everything else as the data
data = table(2:end,:); % cut out multiple Mags
if isempty(data)
    warning('MT catalog empty')
    return
end

FMcatalog = cell2struct(data(:,:),headers1,2);
% clear table data   

% now convert to datenum
dates = (extractfield(FMcatalog,'DATE'));
times = (extractfield(FMcatalog,'TIME'));

for i=1:length(times)
    FMcatalog(i).DateTime = datestr(datenum([cell2mat(dates(i)),' ',cell2mat(times(i))]),'yyyy/mm/dd HH:MM:SS.FFF');
%     if isempty(catalog(i).DEPTH)
%         catalog(i).DEPTH = NaN;
%     end
end

%match fields to old EFIS catalog format
FMcatalog = RenameField(FMcatalog,{'LAT','LON','DEPTH','MAG'},{'Latitude','Longitude','Depth','Magnitude'});
FMcatalog = rmfield(FMcatalog,{'DATE','TIME'});

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