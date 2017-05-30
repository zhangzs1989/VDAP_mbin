%% FalsePositives2 - written by Jay Wellik


%% ALASKA FALSE POSITIVES ANALYSIS

% Known Issues/Things to Keep in Mind
%{
1. This script is an analysis of how often anomalies are followed by eruptions.
It does not analyze how often eruptions are or aren't preceded by anomalies.
I.e., if there is an eruption at a volcano that occurs without any
precursor's ahead of time, that fact is not shown in these results.

2. This analysis is best suited for non-overlapping beta windows that work
backwards in time from the last eruption. In the case of the forward moving
analysis with over-lapping windows, the number of false positives may
increase. This could happen if the beta value is very close to the
empirical threshold and repeatedly rises just above and drops just below
the threshold over a prolonged period of time. So far, I've noticed that
this seems to only affect the final results for time periods when the
volcano had only been in repose for a short number of years.
%}

%% Load proper files

% KNOWN ISSUES: uses eruption-start in some cases where eruption-stop would
% be more appropriate, but is not yet available

clearvars B beta_output fp_lt tp_lt nfp ntp repose_min rm ft forecast_time forecast_matrix RESULTS
clearvars sust_anomaly_binlen sust_anomaly_dates sust_anomaly_repose_days sust_anomaly_precursor_days sust_max_bcBe sust_mean_bcBe
clearvars files

[SUCCESS,MESSAGE,MESSAGEID] = mkdir(params.outDir);

% Reset the volcanoes that you want to run with this group
% params.volcanoes = {'Spurr'; 'Veniaminof'; 'Augustine'; 'Redoubt'; 'Okmok'; 'Kasatochi'; 'Kanaga'; 'Pavlof'; 'Shishaldin'}; % all
% params.volcanoes = {'Spurr'; 'Veniaminof'; 'Augustine'; 'Redoubt'; 'Okmok'; 'Kasatochi'; 'Kanaga'; 'Shishaldin'}; % all - Pavlof
% params.volcanoes = {'Spurr'; 'Veniaminof'; 'Augustine'; 'Redoubt'; 'Okmok'; 'Kasatochi'; 'Pavlof'; 'Shishaldin'}; % all - Kanaga

% params.volcanoes = {'Veniaminof'; 'Kasatochi'; 'Okmok'; 'Pavlof'; 'Shishaldin'}; % open
% params.volcanoes = {'Augustine'; 'Redoubt'; 'Spurr'; 'Kasatochi'; 'Kanaga'}; % closed

% params.volcanoes = {'Augustine', 'Redoubt', 'Pavlof'};

% params.volcanoes = {'Augustine'};

AKeruptions = readtext(inputFiles.Eruptions);
allE = importEruptionsFromSteph2(inputFiles.Eruptions); % import all of Stephanie's eruptions as ERUPTION objects

%%

% Set test parameters for the False Positives Matrix - i.e., what repose
% times and what forecast times will you compare
repose_min = [0 5 10 15 20 25]; % minimum number of years volcano must be in repose for an anomaly to be a false positive
forecast_time = [5 1 8/12 6/12 3/12 1/12 2/52]; % # of years to look for an eruption after an anomaly in order to be considered a true positive

bin_lengths = [30 60 90];
for bin = 1:numel(bin_lengths)
    
    air_matrix = zeros(numel(forecast_time), numel(repose_min)); % matrix of "anomalies in repose" given a repose time and precursor time
    tp_matrix = zeros(numel(forecast_time), numel(repose_min)); % matrix of "true positives" given a repose time and precursor time
    fp_matrix = zeros(numel(forecast_time), numel(repose_min)); % matrix of "false positives" given a repose time and precursor time
    %     forecast_matrix = tp_matrix./(tp_matrix+fp_matrix);
    
    for v = 1:numel(params.volcanoes)
        
        clear BR
        files(v) = subdir(fullfile(params.outDir, params.volcanoes{v}, '*beta_output*'));
        disp(files(v).name)
        load(files(v).name) % loads a variable named 'beta_output'
        si = strfind(files(v).name,filesep);
        volcname = files(v).name(si(end-1)+1:si(end)-1);
        
        % select all eruptions for the volcano in chronological order
        E = chron(objselect(allE, 'volcano_name', volcname));
        
        for b = 1:numel(beta_output)

            B = beta_result(beta_output(b)); % convert the old beta_structure to the new Matlab class of type beta_result
            
            % Make sure the prev and next eruption dates are handled properly
            % use the list of eruptions to set the appropriate previous
            % eruption end and next eruption start for each beta background
            % window
            B = setPrevEruptionEnd(B, E); B = setNextEruption(B, E);
            if isempty(B.prev_eruption_end), B.prev_eruption_end = datenum('Jan 1, 1975'); end
            if isempty(B.next_eruption), B.next_eruption = now; end % if the anomaly occurred after the last recorded eruption, treat now as the next eruption date in order to catch the anomaly as a fp
            if isnan(B.prev_eruption_end), B.prev_eruption_end = datenum('Jan 1, 1975'); end
            if isnan(B.next_eruption), B.next_eruption = now; end % if the anomaly occurred after the last recorded eruption, treat now as the next eruption date in order to catch the anomaly as a fp

            aggregate
            
            RESULTS(b) = B; B;
            
            this_air_matrix = zeros(numel(forecast_time), numel(repose_min)); % matrix of anomalies in repose given a repose time and precursor time
            this_tp_matrix = zeros(numel(forecast_time), numel(repose_min)); % matrix of true positives given a repose time and precursor time
            this_fp_matrix = zeros(numel(forecast_time), numel(repose_min)); % matrix of false positives given a repose time and precursor time
            
            for rm = 1:numel(repose_min)
                
                for ft = 1:numel(forecast_time)
                    
                    % initialize number of anomalies in repos, false
                    % positives, and true positives as zero
                    nair = 0; nfp = 0; ntp = 0;
                    
                    if ~isempty(B.sust_anomaly_repose_days{bin}) && ~isempty(B.sust_anomaly_precursor_days{bin})
                        
                        % "anomaly in repose" logical test (air_lt)
                        air_lt = B.sust_anomaly_repose_days{bin}/365 >= repose_min(rm);
                        
                        % true_positive logical test (tp_lt)
                        tp_lt = B.sust_anomaly_repose_days{bin}/365 >= repose_min(rm) & B.sust_anomaly_precursor_days{bin}/365 <= forecast_time(ft);
                        
                        % false_positive logicla test (lp_lt)
                        fp_lt = B.sust_anomaly_repose_days{bin}/365 >= repose_min(rm) & B.sust_anomaly_precursor_days{bin}/365 > forecast_time(ft);
                        
                        % number of "anomalies in repose"  and number of false positives
                        nair = sum(air_lt);
                        nfp = sum(fp_lt);
                        if sum(tp_lt) >= 1; ntp = 1; else ntp = 0; end; % maximum of 1 true positive per search window is allowed
                        
                    end
                    
%                     FM = FORECAST_MATRIX(B.sust_anomaly_repose_days{bin}{:}, B.sust_anomaly_forecast_times{bin}{:}, repose_min, forecast_time, bin_lengths(bin));

                    % matrices for this particular beta window
                    this_tp_matrix(ft, rm) = ntp;
                    this_fp_matrix(ft, rm) = nfp;
                    this_air_matrix(ft, rm) = nair;
                    this_forecast_matrix = this_tp_matrix./(tp_matrix+fp_matrix);
                    
                    clear nfp ntp
                    
                end
                
                
            end
            
            % add things up at the end of the beta window
            tp_matrix = tp_matrix + this_tp_matrix;
            air_matrix = air_matrix + this_air_matrix;
            fp_matrix = fp_matrix + this_fp_matrix;
            forecast_matrix = tp_matrix./(tp_matrix+fp_matrix);
            
%             tp_matrix, air_matrix, forecast_matrix

        end
        
    end
    
%     pause
    plotFP2
    
end
