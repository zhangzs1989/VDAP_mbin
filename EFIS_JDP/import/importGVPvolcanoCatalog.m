%{

Requires:
readtext, RenameField

%}

clear

ddir = '/Users/jpesicek/Dropbox/Research/EFIS/GVP/';
filename='GVP_volcanoes_v2';
fnameOutName='GVP_volcanoes_v2b';

[table, result]= readtext(fullfile(ddir,[filename,'.csv']),',','','"',''); % OGBURN FILE

% save the first row as the headers
headers1 = table(1,:);
headers1(9) = {'Elevation'};

% save everything else as the data
data = table(2:end,:); % NOTE: cut out NANs at end

volcanoCat = cell2struct(data,headers1,2);
% clear table data

% %match fields to old EFIS catalog format
volcanoCat = RenameField(volcanoCat,{'lat','long','preferred_name','VNUM'},{'Latitude','Longitude','Volcano','Vnum'});
% catalog = rmfield(catalog,{'DATE','TIME'});

I = structfind(volcanoCat,'GeoTimeEpoch','Holocene');
volcanoCat = volcanoCat(I);

types=unique(extractfield(volcanoCat,'GeoTimeEpochCertainty'));

I1 = structfind(volcanoCat,'GeoTimeEpochCertainty',char(types(1)));
I2 = structfind(volcanoCat,'GeoTimeEpochCertainty',char(types(2)));
I3 = structfind(volcanoCat,'GeoTimeEpochCertainty',char(types(3)));

volcanoCat = volcanoCat(sort([I1;I2;I3]));

%% fix unamed volcanoes
II = structfind(volcanoCat,'Volcano','Unnamed');
for l=1:length(II)
    vname = int2str(volcanoCat(II(l)).Vnum);
    volcanoCat(II(l)).Volcano = vname;
end

% QC it:
% lat = extractfield(volcanoCat, 'Latitude');
% long = extractfield(volcanoCat, 'Longitude');

elat = extractfield(volcanoCat, 'Latitude');
elon = extractfield(volcanoCat, 'Longitude');

figure, worldmap('world')
load coast
plotm(lat,long,'k')
plotm(elat,elon,'b.')

[azis,regimes] = getStressAzi(elat,elon,50); % get regional stress directions
% eruptionCat = setfield(eruptionCat,'SHmax',azis);
for i=1:length(elat)
    volcanoCat(i).SHmax = azis(i);
    volcanoCat(i).Regime = regimes(i);
    if strcmp(volcanoCat(i).Elevation,'NAN')
        volcanoCat(i).Elevation = nan;
    end
    if strcmp(volcanoCat(i).composition,'NAN')
        volcanoCat(i).composition = 'Unknown';
    end
    if strcmp(volcanoCat(i).tectonic,'NAN')
        volcanoCat(i).tectonic = 'Unknown';
    end
    if strcmp(volcanoCat(i).GVP_morph_type,'NAN')
        volcanoCat(i).GVP_morph_type = 'Unknown';
    end
    %% fix double named
    
    I = structfind(volcanoCat,'Volcano',volcanoCat(i).Volcano);
    if numel(I)>1
        warning('fixing duplicate volcano name')
        for ii=1:numel(I)
            volcanoCat(I(ii)).Volcano = [volcanoCat(I(ii)).Volcano,'_',int2str(volcanoCat(I(ii)).Vnum)];
            disp(['      ',volcanoCat(I(ii)).Volcano])
        end
    end
    
end

save(fullfile(ddir,[fnameOutName,'.mat']),'volcanoCat');
