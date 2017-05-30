function [baddataRAW,baddataQC,t1,t2] = getNetworkOffDaysFromJiggle(jiggle,volcname,t_start,t_stop,nDaysQC)

%
% nDaysQC: number of consecutive days over which there must be no triggers in order to consider network down

unix_time=jiggle.DATETIME;
date = (unix_time./86400 + datenum(1970,1,1));

% could use structfind here instead, I guess
II = zeros(size(jiggle.B,1),1);
for i=1:size(II,1) 
    % find all possible ways in which the volcano name can appear in modified version of jiggle file 
    if strcmp(jiggle.B{i},['''',volcname,'''']) || ... 
            strcmp(jiggle.B{i},['''',volcname]) || ... 
            strcmp(jiggle.COMMENT{i},['''',volcname,''''])
        II(i)=1;
    end
end
II = logical(II);    
disp([int2str(sum(II)),' triggers in jiggle for ',volcname])

t1=floor(min(date(II)));
t2=floor(max(date(II)));
disp(['First trigger: ',datestr(t1)])
disp(['Last trigger: ',datestr(t2)])

allDays = t1:t2;
daysWithTriggers = unique(floor(date(II))); 
daysWithoutTriggers = setdiff(allDays,daysWithTriggers);
disp(['# of days without triggers: ',int2str(length(daysWithoutTriggers))])

ni(1:length(daysWithoutTriggers)) = ones;

for i=1:nDaysQC:length(daysWithoutTriggers)-nDaysQC
    if daysWithoutTriggers(i) - daysWithoutTriggers(i+nDaysQC) ~= -nDaysQC           
        % then the string of no trigger days is <= n
        % assume that the network is down
        ni(i:i+nDaysQC-1) = 0;        
        
    end
end
ni = logical(ni);
disp(['# of days without triggers after ',int2str(nDaysQC),' day QC test: ',int2str(length(daysWithoutTriggers(ni)))])

baddataRAW = daysWithoutTriggers;
baddataQC = daysWithoutTriggers(ni);

ib = baddataRAW > t_start & baddataRAW < (t_stop);
baddataRAW = baddataRAW(ib);

ib = baddataQC > t_start & baddataQC < (t_stop);
baddataQC = baddataQC(ib);

end