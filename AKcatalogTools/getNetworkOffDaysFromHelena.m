function baddata = getNetworkOffDaysFromHelena(volcname,t_start,eruption_windows)

load('/Volumes/EFIS_seis/share/GOLD_STAR_FOR_HELENA/MONITOREDVOLCANO.mat');
vnames = extractfield(VOLCANO,'name');

% % get volc coords
% for i=1:size(vnames,2)
%     TF = strcmp(volcname,vnames(i));
%     if TF
%         break
%     end
% end
% if ~TF; error('ERROR: no volcano match found'); end;

i = structfind(VOLCANO,'name',volcname);
if isempty(i); error('ERROR: no volcano match found'); end;

VOLCANO1 = VOLCANO(i); VOLCANO1.name
clear VOLCANO

% get number of days of network down time
ib = VOLCANO1.baddata > t_start & VOLCANO1.baddata < max(max(eruption_windows));
baddata = VOLCANO1.baddata(ib);

disp([int2str(length(baddata)),' baddata days from H. Buurman for ',volcname])

end