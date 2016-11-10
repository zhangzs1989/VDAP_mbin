function beta_output = prepAndDoBetas(vinfo,eruption_windows,params,inputFiles,catalog,baddata)
%% PREPANDDOBETAS Handles all operations related to the Beta analysis


%{
%DEPENDENCIES:
%EXCLUSION2TESTWINDOWS
%SERIES2PERIOD

INPUT:
-

OUTPUT:
-BETA_OUTPUT - structure array of information related to beta analysis;
each structure element corresponds to a window in 'eruption_windows' (i.e.,
in practice, supposed to be a period of quiesence)

%}

%% Create new catalog to be used specifically for beta analysis

% NOTES AND EXPLANATIONS FOR THIS BLOCK BELOW:
%{
THESE STEPS EXPLAIN THE COMMANDS IN THE BLOCK BELOW:

(a) BACK_WINDOWS Periods of background activity (includes unhealthy network time periods)
Uses the time of the first and last event in the catalog as the start and
stop of the analysis, respectively.
Uses 'exclusion2testwindow' switch the time of eruptions (i.e., the time to
exclude) to background times (i.e., times to keep).
NOTE: Unhealthy network times are still included after this step.
see EXCLUSION2TESTWINDOWS

(b) GOOD_WINDOWS Catalog for events that are considered background and have good network health
These are the time windows you will send to run_betas.
Merge background windows with bad data days - result is
start/stop times for periods that are considered background and have
good data.
This is how we remove data from poor data quality time
periods; the third input parameter is the amount of time (in days) that
must pass for the gap to be labelled bad.
see SERIES2PERIOD

(c) BETA_BACK_CATALOG Catalog events from time period of background periods that have a healthy network
Filter the data so that it only keeps events in the background windows with
good data.
Uses n-by-2 matrix of start/stop times to filter the data

(d) BETA_BACK_CATALOG_TIMES Times that you will send to run_betas
Extract event times from catalog
%}

% filter the catalog as per the steps listed above
% NOTE: Each line of code below carries a alphabet-marker from the list above to explain what is happening

% JP: changes to pass VEI through and to allow no eruption_windows
if isempty(eruption_windows)
    exclude_windows = [];
else
    exclude_windows = eruption_windows(:,1:2);
end

back_windows = exclusion2testwindows(datenum(catalog(1).DateTime), datenum(params.catalogEndDate), exclude_windows); % (a)
good_windows = series2period(back_windows, baddata, 1, 'exclude'); % (b)
beta_back_catalog = filterTime( catalog, good_windows(:,1), good_windows(:,2)); disp(['Events: ',int2str(numel(catalog))]) % (c)
beta_back_catalog_times = datenum(extractfield(beta_back_catalog, 'DateTime')); % (d)

%%
beta_output = run_betas( beta_back_catalog_times, good_windows, 'all', params, vinfo); % calculates empirical beta and beta for moving windows
% beta_output = run_betas( beta_back_catalog_times, good_windows, params.ndays_all, 'all', params.it, params.be_thresPer, params.spacing, params.retro); % calculates empirical beta and beta for moving windows

% include 'next_eruption' info in each beta_structure - necessary later
% for determining precursory activity
%{
    NOTE: This is a little messy. There could probably be a lot of
    improvments made to the beta structure so that it is usable in future
    applications. I'm adding 'next_eruption' in this messy way so that I
    don't interfere with the current beta structure and the associated
    functions, because I think they are pretty usable in terms of being
    able to be applied to future applications.
%}

eruption_windows = [0 0 0 0 0; eruption_windows]; % adding a set of zeros at the beggining fixes the problem if there are no eruptions at the volcano
eruption_dates = eruption_windows; % dates of eruptions
for n = 1:numel(beta_output)
    
    I = find(eruption_dates >= beta_output(n).stop, 1, 'first');
    beta_output(n).next_eruption = eruption_dates(I,1); % the date of the next provided eruption
    beta_output(n).next_eruptionVEI = eruption_dates(I,3); % the date of the next provided eruption
    
    I = eruption_dates(:, 2) <= beta_output(n).start;
    beta_output(n).prev_eruption_end = max(eruption_dates(I, 2)); % the end date of the previous provided eruption (* see programming note)
    beta_output(n).prev_eruption_endVEI = max(eruption_dates(I, 3)); % the end date of the previous provided eruption (* see programming note)
    
    if isempty(beta_output(n).next_eruption), beta_output(n).next_eruption = nan; end; % if there is no eruption after this set of beta data
    if isempty(beta_output(n).next_eruptionVEI), beta_output(n).next_eruptionVEI = nan; end; % if there is no eruption after this set of beta data
    if isempty(beta_output(n).prev_eruption_end), beta_output(n).prev_eruption_end = NaN; end; % if there is no eruption after this set of beta data
    if isempty(beta_output(n).prev_eruption_endVEI), beta_output(n).prev_eruption_endVEI = NaN; end; % if there is no eruption after this set of beta data
    
    beta_output(n).bin_mag = cumMagByBetaBin(params.ndays_all, beta_output(n).t_checks, extractfield(catalog, 'DateTime'), extractfield(catalog, 'Magnitude'));
    
end

% * Programming Note - end date of the previous eruption
%{
beta_output(n).prev_eruption_end = max(eruption_dates(eruption_dates(:, 2)<= beta_output(n).stop, 2));

If you work from the inner-most parantheses outwards, this line of code
does the following:

Do a logical test comparing all dates in the second column of eruption_dates
 (i.e., the end of the eruptions) that are less than or equal to the start
 date of this beta window:
1 >> eruption_dates(:, 2) <= beta_output(n).start
E.g., result -> [1 1 0 0 0]

for all rows for which that is true, return just the second column; i.e.,
 the end date of the eruption.
2 >> eruption_dates(eruption_dates(:, 2) <= beta_output(n).start, 2)
E.g., result -> [723815 724102]

Grab the most recent eruption end date that is returned from the previous
 line - i.e., the max() of the result
3 >> max(eruption_dates(eruption_dates(:, 2) <= beta_output(n).start, 2))
E.g., 724102

Final notes:
If the result of Step 1 is all logical 0s - i.e., there is no prev.
eruption - the final result of Step 3 should be a 0-by-1 Empty Matrix.
Subsquent lines of code will replace an empty value w NaN

%}

% save the output
save(fullfile(params.outDir,vinfo.name,'beta_output.mat'), 'beta_output'); % save beta data to output directory

%% make beta plots
% first do t1-t2 for whole time series
if params.doSwarmPlot
    disp('Enter swarm plot...')
    
    swarm_plots = swarmPlot7(catalog,vinfo,params,beta_output,eruption_windows,baddata,inputFiles);
    
    %find most useful time boundaries
    % t1o = beta_back_catalog_times(1)-1;
    t1o = min([beta_back_catalog_times(1)-1; params.betaBackgroundType(1); vinfo.NetworkStartDay]);
    % t2o = beta_back_catalog_times(length(beta_back_catalog_times))+1;
    t2o = max([beta_back_catalog_times(length(beta_back_catalog_times))+1; params.betaBackgroundType(2); params.catalogEndDate]);
    
    xlim([t1o t2o]);
    if size(catalog,2) == 1
        catTitle = 'Jiggle';
    else
        catTitle = 'ANSS';
    end
    title(swarm_plots(2),{[vinfo.name,': ',catTitle],[datestr(t1o,'mm/dd/yyyy') ' to ' datestr(t2o,'mm/dd/yyyy')]})
    % set(swarm_plots(1),'PaperPositionMode','auto')
    
    outDirName=[params.outDir,'/',vinfo.name];
    if ~exist(outDirName,'dir')
        [~,~,~] = mkdir(outDirName);
    end
    
    print(swarm_plots(1),'-dpng',[outDirName,'/',vinfo.name,'_Beta_',catTitle,'_all'])
    savefig(swarm_plots(1),[outDirName,'/',vinfo.name,'_Beta_',catTitle]);
    
    % loop over eruption windows
    for i=2:size(eruption_windows,1) %JP: start at two to account for adding zeros to beginning fix above
        
        t1 = eruption_windows(i,1) - params.BetaPlotPreEruptionTime;
        t2 = eruption_windows(i,2);
        title(swarm_plots(2),{[vinfo.name,': ',catTitle],[datestr(t1,'mm/dd/yyyy') ' to ' datestr(t2,'mm/dd/yyyy')]})
        xlim([t1 t2]);
        
        print(swarm_plots(1),'-dpng',[outDirName,'/',vinfo.name,'_Beta_',catTitle,'_',int2str(i-1)])
        %     set(swarm_plots(1),'PaperPositionMode','auto')
        
    end
    
    if nnz(eruption_windows)~=0
        try
            % now plot time since last eruption
            t1 = max(max(eruption_windows));
            t2 = beta_back_catalog_times(length(beta_back_catalog_times))+1;
            title(swarm_plots(2),{[vinfo.name,': ',catTitle],[datestr(t1,'mm/dd/yyyy') ' to ' datestr(t2,'mm/dd/yyyy')]})
            xlim([t1 t2]);
            print(swarm_plots(1),'-dpng',[outDirName,'/',vinfo.name,'_Beta_',catTitle,'_recent'])
        end
    end
    xlim([t1o t2o]);
    title(swarm_plots(2),{[vinfo.name,': ',catTitle],[datestr(t1o,'mm/dd/yyyy') ' to ' datestr(t2o,'mm/dd/yyyy')]})
end
