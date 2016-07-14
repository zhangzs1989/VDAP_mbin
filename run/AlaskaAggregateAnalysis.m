%% ALASKA AGGREGATE ANALYSIS
% Collects output data from all volcanoes and analyzes them as a whole


%% Analyze Timing of Beta Anomalies Relative to Eruption
% Looks at all beta anomalies and analyzes them based on when they occur
% prior to eruptions.
% For eruptions that showed beta anomalies immediately preceeding the
% eruption, this script shows how far in advance those beta anomalies
% occurred.

%% Load proper files

    % get all beta files from the output directory
files = subdir(fullfile(params.outDir, '*beta_output*')); 

    % initialize a variable that will hold every beta analysis that was conducted for the volcanoes (size is not known)
all_beta_output = [];

    % load all beta_output variables
for n = 1:length(files)
    
    load(files(n).name); % loads a variable named 'beta_output'
    all_beta_output = [all_beta_output beta_output]; % append newly loaded 'beta_output' to the end of all_beta_output
    
end

%% send to external script for analysis

    % computes all statistics on when anomalies occur
    % and when first sustained anomaly occurred
    % this is done for each specific background window
[all_beta_output, agg_data] = betaAnomalyTiming1A( all_beta_output );


%%

    % all anomalies - combine statistics into single vector
all_anomalies_bins{1,3} = []; % preallocate size
for n = 1:length(all_beta_output(1).anomaly_precursor_bins) % for each beta bin size
    
    for i = 1:length(all_beta_output) % gather stats through each background window
       
            % all anomalies - bins before the next eruption
       all_anomalies_bins{n} = [all_anomalies_bins{n}; all_beta_output(i).anomaly_precursor_bins{n}];
       
    end
    
        % sort elements in order
    all_anomalies_bins{n} = sort(all_anomalies_bins{n});
    
end

    % earliest precursor - bins before eruption
all_sust_precursors_bins = []; % initialize
for i = 1:length(all_beta_output)
    
            %{
            NOTE: syntax can be simple bc this is always
            the length of the result is always the same (stub size =
            1-by-3) for each background window and data are stored as
            (stub, 1-by-3) vector, not a cell array
            %}
       all_sust_precursors_bins = [all_sust_precursors_bins; all_beta_output(i).earliest_sust_anomaly_bins];
        
    
end

%% Plot results - Earliest Precursor
% NOTE - A lot of work needs to be done in the plotting here. There's a lot
% of manual stuff that should be automated or looped over.
% NOTE - Information about bins is plotted, but the x axis and x label are
% re-worked so that it reads as days.

f = figure;
total_beta_windows = 3; % pull this from the beta_output script
hist_increments = 1; % histogram bin size

for n = 1:total_beta_windows;
    
    subplot(total_beta_windows,1,n); % creates a vertical display of plots in the same figure window
    
    % neruptions = numel(all_sust_precursors_bins); % total number of eruptions - !!!!!!!!!!!! NOT CORRECT !!!!!!!!!!
    neruptions = 18; % stub - needs to be automated
    
    neruptions_with_prec = sum(~isnan(all_sust_precursors_bins(:,n))); % the number of eruptions with a precursory beta anomaly immediately before the eruption
    percEruptions_with_prec = neruptions_with_prec / neruptions * 100; % percentage of eruptions with a precursory beta anomaly immediately before the eruption
    drange = min(all_sust_precursors_bins(:,n)):hist_increments:max(all_sust_precursors_bins(:,n)); % create the range used for the histogram
    hist(all_sust_precursors_bins(:,n),drange); % compute the histogram
    title({'First Precursory Beta Anomaly';...
        [num2str(beta_output(1).bin_sizes(n)) ' day beta window'];...
        [num2str(neruptions-neruptions_with_prec) ' of ' num2str(neruptions) ' (' num2str(100-percEruptions_with_prec,'%2.1f'),...
        '%) eruptions had no beta anomaly immediately before the eruption']});
    
    
    a = gca;
    ax(n) = a;
    ax(n).XTick = 1:2:max(a.XTick);
    ax(n).XTickLabel = strread(num2str(a.XTick * beta_output(1).bin_sizes(n)),'%s');
    ylabel('Counts')
    
end

ax(end).XLabel.String = 'Days Before Eruption';


%% Plot results - All anomalies
% NOTE - Information about bins is plotted, but the x axis and x label are
% re-worked so that it reads as days.

f = figure;

for n = 1:total_beta_windows;
    
    subplot(total_beta_windows,1,n);
    
    drange = min(agg_data.anomaly_precursor_days{n}):hist_increments:max(agg_data.anomaly_precursor_days{n}); 
    hist(agg_data.anomaly_precursor_days{n}, drange)
    title({'All Beta Anomalies';...
        [num2str(beta_output(1).bin_sizes(n)) ' day beta window']});
    
    b = gca;
    ax2(n) = b;
    ax2(n).XTick = beta_output(1).bin_sizes(n):beta_output(1).bin_sizes(n)*104:max(b.XTick);
%     ax2(n).XTickLabel = strread(num2str(b.XTick * beta_output(1).bin_sizes(n)),'%s');
    ylabel('Counts')
    
end

% ax2(end).XLabel.String = 'Days Before Eruption';

