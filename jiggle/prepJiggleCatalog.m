function catalog = prepJiggleCatalog(volcname,jiggle)

% create a catalog structure from the jiggle file to match our ANSS struct
% use only the times.  You could also populate location info for those that
% were located but the trigger times differ from origin times.  Best to
% just keep these data separate and use trigger times only
%
% this is a big file, don't load every time
% load('/Volumes/EFIS_seis/share/jiggle.mat');
% also it is not perfectly prepared by previous import.  Did best we could.
%
% output includes events of type: longperiod, local, other, regional
% FUTURE WORK: could further filter by event type if desired
% J. PESICEK Nov 2015

unix_time=jiggle.DATETIME;
date = (unix_time./86400 + datenum(1970,1,1));

% find all possible ways in which the volcano name can appear in modified version of jiggle file
% this was tested on veniaminof and does get all instances of name in
% jiggle file, should test on others I guess

II = zeros(size(jiggle.B,1),1);
for i=1:size(II,1)
    if strcmp(jiggle.B{i},['''',volcname,'''']) || ... % volcano name in quotes
            strcmp(jiggle.B{i},['''',volcname]) || ...  % front quote only
            strcmp(jiggle.COMMENT{i},['''',volcname,'''']) % in wrong column, with quotes
        II(i)=1;
    end
end
II = logical(II);
disp([int2str(sum(II)),' triggers in jiggle for ',volcname])

if sum(II)
    t1=floor(min(date(II)));
    t2=floor(max(date(II)));
    disp(['First trigger: ',datestr(t1)])
    disp(['Last trigger: ',datestr(t2)])
    
    DateTime = date(II); % filter to triggers associated with specific volcano
    
    % ic = DateTime > min(min(t_onset)) & DateTime < max(max(t_onset));
    % disp([int2str(sum(ic)),' triggers in jiggle for ',volcname,' within t_onset '])
    %
    % DateTime = DateTime(ic); % filter to match time period range in t_onsets
    
    catalog = struct('DateTime',cellstr(datestr(DateTime)));
else
    catalog =[];
end

% add these fields for consistency with other filters??
% for i=1:length(DateTime)
%     catalog(i).Source = 'AV'; % network code
%     catalog(i).Longitude = NaN;
%     catalog(i).Latitude = NaN;
%     catalog(i).Depth = NaN;
%     catalog(i).Magnitdue = NaN;
% end

end