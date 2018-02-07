
gemCatFile='/Users/jpesicek/Dropbox/Research/EFIS/ISC/GEM/isc-gem/isc-gem-cat.csv';
filename = 'catalogGEM';
ddir='/Users/jpesicek/Dropbox/Research/EFIS/ISC/GEM';

[data, result] =readtext(gemCatFile);

header = data(60,:);
header(1) = {'DateTime'};
header(2) = {'Latitude'};
header(3) = {'Longitude'};
header(8) = {'Depth'};
header(24)= {'EVENTID'};
header(11)= {'Magnitude'};
%%
j=0;
for i=61:length(data)
    j=j+1;
    
    for k=1:length(header)
        
        catalog(j).(header{k}) = cell2mat(data(i,k));
        
    end
    catalog(j).MagType = 'Mw';
    catalog(j).DateTime = datestr(datenum(catalog(j).DateTime,'yyyy-mm-dd HH:MM:SS.FFF'),'yyyy/mm/dd HH:MM:SS.FFF');
    catalog(j).AUTHOR = 'GEM';

end

%% cut events from 1964 on
dts = extractfield(catalog,'DateTime');
I = datenum(dts) < datenum(1964,1,1);

catalogGEM = catalog(I);
save(fullfile(ddir,[filename,'.mat']),'catalogGEM');
