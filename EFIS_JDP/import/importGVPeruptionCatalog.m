%{

Requires:
readtext, RenameField

%}

clear

ddir = '/Users/jpesicek/Dropbox/Research/efis/GVP/';
filename='GVP_eruptions_with_ids_v2';
    
[table, result]= readtext(fullfile(ddir,[filename,'.csv']),',','','"',''); % OGBURN FILE

% save the first row as the headers
headers1 = table(1,:);
headers1(6) = {'VEI_max'};

%fix non-word header vals that cell2struct doesn't seem to like
pat = '\W';
for i=1:length(headers1)
    str = char(headers1(i));
    str2=regexprep(str,pat,'_');
    headers1(i) = {str2};
end
    
% save everything else as the data
data = table(2:end,:); % cut out multiple Mags

eruptionCat = cell2struct(data,headers1,2);
% clear table data   
I = structfind(eruptionCat,'activity_type','Confirmed Eruption');

eruptionCat = eruptionCat(I);

% now convert to datenum
startDate = (extractfield(eruptionCat,'start_date'));
endDate = (extractfield(eruptionCat,'end_date'));
VEI_max = extractfield(eruptionCat,'VEI_max');
% times = (extractfield(catalog,'TIME'));
start_day = extractfield(eruptionCat,'start_day');

for i=1:length(startDate)
    eruptionCat(i).StartDate = datestr(datenum([cell2mat(startDate(i))]),'yyyy/mm/dd HH:MM:SS.FFF');
    if strcmp(endDate(i),'NAN')
        eruptionCat(i).EndDate = [];
    else
        eruptionCat(i).EndDate = datestr(datenum([cell2mat(endDate(i))]),'yyyy/mm/dd HH:MM:SS.FFF');
    end

    if strcmp(VEI_max(i),'NAN')
        eruptionCat(i).VEI_max = NaN;
    end    
    if strcmp(start_day(i),'NAN')
        eruptionCat(i).start_day = NaN;
    end    
    if strcmp(eruptionCat(i).repose_before_eruption,'NAN')
        eruptionCat(i).repose_before_eruption = NaN;
    end        
end
% deps = extractfield(catalog,'DEPTH');
% 
eruptionCat = RenameField(eruptionCat,{'VNUM'},{'Vnum'});
II = structfind(eruptionCat,'volcano','Unnamed');
for l=1:length(II)
    vname = int2str(eruptionCat(II(l)).Vnum);
    eruptionCat(II(l)).volcano = vname;
end% 

types=unique(extractfield(eruptionCat,'activity_type'));

I1 = structfind(eruptionCat,'activity_type',char(types(1)));
eruptionCat = eruptionCat(sort([I1]));

% cut those before 1964 when ISC monitoring is good
starts = extractfield(eruptionCat,'StartDate');
I = find(datenum(starts)>=datenum(1964,1,1));
eruptionCat = eruptionCat(I);
% QC it:

% save('/Users/jpesicek/Research/Alaska/catsearch.20704.mat','catalog');
save(fullfile(ddir,[filename,'.mat']),'eruptionCat');
