%% inquiry2
% Post-eruptive swarms

ELOG = [];

AVO_LOG = readtable('/Users/jjw2/Dropbox/JAY-DATA/AVO_eruptiondates.txt');
AVO_LOG.start = datetime(AVO_LOG.start, 'InputFormat', 'yyyy/MM/dd');
AVO_LOG.stop = datetime(AVO_LOG.stop, 'InputFormat', 'yyyy/MM/dd');

gap = 180; % # of days allowed inbetween explosions to count as an ongoing eruption

closed_volcanoes = {'Spurr', 'Augustine', 'Redoubt', 'Kasatochi', 'Kanaga'};


for l = 1:height(LOG)
    
    %%% new analysis
    
    % pare down AVO_LOG to only those for this volcano; get eruption s/s
    avo_log = AVO_LOG(strcmpi(AVO_LOG.volcano, LOG.volcano_name{l}), :);
    avo_ss = [avo_log.start, avo_log.stop];
    
    % get all explosion dates from EFIS database
    ss = get(LOG.DATA(l).E, 'start_stop');

    for i = 1:size(avo_ss, 1)
    
        % check to make sure all explosion dates are within an eruption date
        [data, idx, idxmat] = withininterval(ss(:,1), avo_ss(i,:), 1);
        sprintf('There are %i explosions outside the eruption window', ...
            sum(idx==0))
        ss(idx==0, :) = []; % remove those extraneous explosions for now
    
        % define last explosion for each eruption
%       last_exp(i) = datetime2(max(idxmat(i,:) .* data));
        if ~isempty(data)
            last_exp(i) = datetime2(max(data));
        else
            last_exp(i) = avo_ss(i,2);
        end
            
        % get highest number of counts
        %   A  -> prior to eruption
        %   B  -> during eruption
        %   C -> after an eruption
        %       B1/C1 -> with avo end date as the end date
        %       B2/C2 -> with last explosion as end date
        
        % get original table
        T = table(LOG.DATA(l).tc, LOG.DATA(l).binCounts, 'VariableNames', ...
            {'tc', 'binCounts'});
        
        % A
        premax(i) = max([0; T{T.tc > avo_ss(i,1)-gap/2 & T.tc < avo_ss(i,1), 'binCounts'}]);
        
        % B
        intramax1(i) = max([0; T{T.tc >= avo_ss(i,1) & T.tc <= avo_ss(i,2), 'binCounts'}]);
        intramax2(i) = max([0; T{T.tc >= avo_ss(i,1) & T.tc <= last_exp(i), 'binCounts'}]);

        % C
        postmax1(i) = max([0; T{T.tc > avo_ss(i,2) & T.tc < avo_ss(i,2)+gap/2, 'binCounts'}]);
        postmax2(i) = max([0; T{T.tc > last_exp(i) & T.tc < last_exp(i)+gap/2, 'binCounts'}]);

        n = numel(ELOG)+1;
        ELOG(n).volcano_name = LOG.volcano_name{l};
        ELOG(n).eruptionss = avo_ss(i,:);
        ELOG(n).annulus = LOG.annulus(l,:);
        ELOG(n).maxdepth = LOG.maxdepth(l);
        ELOG(n).minmag = LOG.minmag(l);
        ELOG(n).t_window = LOG.t_window(l,:);
        ELOG(n).include_intraeruption = LOG.include_intraeruption(l);
        ELOG(n).use_triggers = LOG.use_triggers(l);
        ELOG(n).maxcounts1 = [premax(i) intramax1(i) postmax1(i)];
        ELOG(n).maxcounts2 = [premax(i) intramax2(i) postmax2(i)];

        
        clear premax intramax postmax
        
    end
    
end

ELOG = struct2table(ELOG);

%% Distill answers from ELOG

choice.annulus = [0 30];
choice.maxdepth = [30];
choice.minmag = [0];
choice.t_window = [1 90];
choice.include_intraeruption = [1];
choice.use_triggers = [1];
choice.use_last_exp = [0]; % { [0] | [1] } 1 -> eruption stop is last explosion; 0 -> AVO definition 

disp('ALL ERUPTIONS IN THIS LOG')
a = ELOG(ELOG.annulus(:,1)==choice.annulus(1) ...
    & ELOG.annulus(:,2)==choice.annulus(2) ...
    & ELOG.minmag==choice.minmag ...
    & ELOG.maxdepth==choice.maxdepth ...
    & ELOG.t_window(:,1)==choice.t_window(1) ...
    & ELOG.t_window(:,2)==choice.t_window(2) ...
    & ELOG.include_intraeruption==choice.include_intraeruption ...
    & ELOG.use_triggers==choice.use_triggers ...
    ,:);
disp(a), disp(' ')

disp('What percentage of eruptions had EQ swarms after the last eruptive episode that was greater than pre-eruptive episodes?')
b = a(a.maxcounts1(:,3) >= a.maxcounts1(:,1), :);
disp([num2str(height(b)/height(a)*100) '%'])
disp(b), disp(' ')

disp('What percentage of eruptions had EQ swarms after the last eruptive episode that was greater than intra-eruptive episodes?')
c = a(a.maxcounts1(:,3) >= a.maxcounts1(:,2), :);
disp([num2str(height(c)/height(a)*100) '%'])
disp(c), disp(' ')

%% Make Pie Charts


no = 1
yes = 15


a_closed = a(contains(a.volcano_name, closed_volcanoes), :);
a_open = a(~contains(a.volcano_name, closed_volcanoes), :);

%%% Greater than Pre-Eruptive (Closed & Open)
pf = figure

subplot(1,2,1) % Closed
yes = sum(a_closed.maxcounts1(:, 3) >= a_closed.maxcounts1(:,1))
no = sum(a_closed.maxcounts1(:, 3) < a_closed.maxcounts1(:,1))
iavcei_I2_pie(yes, no);

subplot(1,2,2) % Open
yes = sum(a_open.maxcounts1(:, 3) >= a_open.maxcounts1(:,1))
no = sum(a_open.maxcounts1(:, 3) < a_open.maxcounts1(:,1))
iavcei_I2_pie(yes, no);

pf.Color = [1 1 1];
pf.Children(1).Title.FontSize = 28;
pf.Children(2).Title.FontSize = 28;
pf.Position = [837 1024 723 314];
export_fig(pf, '~/Desktop/test_pre.png', '-transparent')


%%% Greater than Intra-Eruptive (Closed & Open)
pf = figure

subplot(1,2,1) % Closed
yes = sum(a_closed.maxcounts1(:, 3) >= a_closed.maxcounts1(:,2))
no = sum(a_closed.maxcounts1(:, 3) < a_closed.maxcounts1(:,2))
iavcei_I2_pie(yes, no);

subplot(1,2,2) % Open
yes = sum(a_open.maxcounts1(:, 3) >= a_open.maxcounts1(:,2))
no = sum(a_open.maxcounts1(:, 3) < a_open.maxcounts1(:,2))
iavcei_I2_pie(yes, no);

pf.Color = 'none';
pf.Children(1).Title.FontSize = 28;
pf.Children(2).Title.FontSize = 28;
pf.Position = [837 1024 723 314];
export_fig(pf, '~/Desktop/test_intra.png', '-transparent')





