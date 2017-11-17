% combine the event and FM catalogs into one.  Should have done this in the
% first place

clear

ddir1 = '/Users/jpesicek/dropbox/Research/EFIS/ISC/getISCcat4';
ddir2 = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/getISC_FMs';
filename1='iscCatalogAll5';
filename2='iscFM_All';
filename = 'iscCatalogAll5wFMs';

load(fullfile(ddir1,filename1))
load(fullfile(ddir2,filename2))

FMID = extractfield(FMcat,'EVENT_ID');
EVID = extractfield(catalog,'EVENTID');

for l=1:length(FMID)
    I=find(FMID(l)==EVID);
    if ~isempty(I)
        catalog(I).MT = FMcat(l);
    elseif length(I)>1
        warning('MORE THAN ONE FM returned, taking first')
        catalog(I(1)).MT = FMcat(l);
    end
end

save(fullfile(ddir1,filename))