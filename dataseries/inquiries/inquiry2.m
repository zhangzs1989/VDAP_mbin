%% inquiry2
% Post-eruptive swarms

ELOG = [];

for l = 1:height(LOG)
    
    % * cluseter scattered eruptions into single eruption
    gap = 150; % # of days allowed inbetween explosions to count as an ongoing eruption
    ss = get(LOG.DATA(l).E, 'start_stop');
    ss(:,2) = ss(:,2)+gap;
    ss = mergeintervals(ss);
    ss(:,2) = ss(:,2)-gap;
    
    % * get highest number of counts prior to eruption, during eruption, and
    % after eruption
    for i = 1:size(ss,1)
        T = table(LOG.DATA(l).tc, LOG.DATA(l).binCounts, 'VariableNames', ...
            {'tc', 'binCounts'});
        premax(i) = max([0; T{T.tc > ss(i,1)-gap & T.tc < ss(i,1), 'binCounts'}]);
        intramax(i) = max([0; T{T.tc >= ss(i,1) & T.tc <= ss(i,2), 'binCounts'}]);
        postmax(i) = max([0; T{T.tc > ss(i,2) & T.tc < ss(i,2)+gap, 'binCounts'}]);

        n = numel(ELOG)+1;
        ELOG(n).volcano_name = LOG.volcano_name{l};
        ELOG(n).eruptionss = ss(i,:);
        ELOG(n).annulus = LOG.annulus(l,:);
        ELOG(n).maxdepth = LOG.maxdepth(l);
        ELOG(n).minmag = LOG.minmag(l);
        ELOG(n).t_window = LOG.t_window(l,:);
        ELOG(n).include_intraeruption = LOG.include_intraeruption(l);
        ELOG(n).use_triggers = LOG.use_triggers(l);
        ELOG(n).maxcounts = [premax(i) intramax(i) postmax(i)];
        
        clear premax intramax postmax
        
    end
    
    % * compare which eruptions have a swarm at a % percentage of pre- or
    % intra- eruptive seismicity
    
    
end

ELOG = struct2table(ELOG);

%% Distill answers from ELOG

choice.annulus = [0 30];
choice.maxdepth = [30];
choice.minmag = [0];
choice.t_window = [1 90];
choice.include_intraeruption = [1];
choice.use_triggers = [1];

disp('ALL ERUPTIONS IN THIS LOG')
a = ELOG(ELOG.annulus(:,1)==choice.annulus(1) ...
    & ELOG.annulus(:,2)==choice.annulus(2) ...
    & ELOG.minmag==choice.minmag ...
    & ELOG.maxdepth==choice.maxdepth ...
    & ELOG.t_window(:,1)==choice.t_window(1) ...
    & ELOG.t_window(:,2)==choice.t_window(2) ...
    & ELOG.include_intraeruption==choice.include_intraeruption ...
    & ELOG.use_triggers==choice.use_triggers ...
    & ELOG.maxcounts(:,1)~=0, :);
disp(a), disp(' ')

disp('What percentage of eruptions had EQ swarms after the last eruptive episode that was greater than pre-eruptive episodes?')
b = a(a.maxcounts(:,3) >= a.maxcounts(:,1), :);
disp([num2str(height(b)/height(a)*100) '%'])
disp(b), disp(' ')

disp('What percentage of eruptions had EQ swarms after the last eruptive episode that was greater than intra-eruptive episodes?')
c = a(a.maxcounts(:,3) >= a.maxcounts(:,2), :);
disp([num2str(height(c)/height(a)*100) '%'])
disp(c), disp(' ')









