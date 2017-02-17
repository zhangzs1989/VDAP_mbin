function [beta_structure, aggregate_data] = betaAnomalyTiming1A( beta_structure )
% BETAANOMALYTIMING Returns information about when beta anomalies occur
% relative to future eruptions.
%
% INPUT
% beta_structure : the output structure from run_betas
%
% OUTPUT

    % commands needed for development
% load('Augustine_beta_output.mat')
% load('Augustine_eruption_windows.mat')

%% Get Anomalies > Beta, Get Deviation (+/-) from Beta

clear is_over_beta, clear dev_from_beta

nbins = numel(beta_structure(1).bin_sizes);
aggregate_data.anomaly_precursor_days{1,nbins} = [];
aggregate_data.anomaly_precursor_bins{1,nbins} = [];

for n = 1:length( beta_structure )
    
        % extract variables for brevity
    Be = beta_structure(n).Be;
    bc = beta_structure(n).bc;
    t_checks = beta_structure(n).t_checks;
    bin_sizes = beta_structure(n).bin_sizes;
    Be_matrix = repmat(Be, size(bc,1), 1); % repeats the row vector of Be values for n rows so that it is same size as bc matrix; allows you to vectorize operations later 
%     bin_size_mat = repmat(bin_sizes, size(bc,1), 1); % see comment from line above
    
    % create vectors that identify:
    % is_over_beta : whether the beta value for each t_check is anomalous or not
    % dev_from_beta : the percent which the beta value differs from beta empirical
    is_over_beta = bc > Be_matrix;  %%JP: should this be >= ???
    bcBe_ratio = bc./Be_matrix;
       
        % days and bins of anomalies - reported in amount of time before
        % eruption
    [anomaly_precursor_days, anomaly_precursor_bins] = getAnomalyPrecursors( beta_structure(n).next_eruption, t_checks, bcBe_ratio, bin_sizes );
    [early_sust_anom_days, eary_sust_anom_bins] = getEarliestSustainedAnomaly( anomaly_precursor_bins, bin_sizes );
    
        % save all stats to this beta_structure
    beta_structure(n).is_over_beta = is_over_beta;
    beta_structure(n).bcBe_ratio = bcBe_ratio;
    
    beta_structure(n).anomaly_precursor_days = anomaly_precursor_days;
    beta_structure(n).anomaly_precursor_bins = anomaly_precursor_bins;
    beta_structure(n).earliest_sust_anomaly_days = early_sust_anom_days;
    beta_structure(n).earliest_sust_anomaly_bins = eary_sust_anom_bins;
    
    for j = 1:numel(anomaly_precursor_days)
    
        aggregate_data.anomaly_precursor_days{j} = [aggregate_data.anomaly_precursor_days{j}; anomaly_precursor_days{j}];
        aggregate_data.anomaly_precursor_bins{j} = [aggregate_data.anomaly_precursor_bins{j}; anomaly_precursor_bins{j}];
    
    end
    
end

%% sub-routines

    function [days, bins] = getAnomalyPrecursors( event_time, t_checks, ratio, window_sizes )
        %GETANOMALYPRECURSORS Returns a vector of times that are anomalous for
        %each beta window size. Result is returned as number of days and number
        %of bins.
        %Output is a n-sized structure ... (?)
        
        for col = 1:size(ratio,2) % for each column (columns correspond to the beta window size)
%      for col = 1
     
            %if ~isnan(event_time), disp(datestr(event_time)); else, disp('No event time'); end
            times = t_checks(:,col); % datestr(min(times)) % times for this column (ie, for this beta window size) - have to do it this way bc I can't figure out how to vectorize it
            %disp(datestr(min(times( ratio(:,col) > 1 ))))
            days{col} = event_time - times( ratio(:,col) > 1 ); % max(days{col}) % precursory days - only for anomalies
            bins{col} = days{col} / window_sizes(col); % max(bins{col}) % precursory bins - only for anomaliles
            
        end
        
        
    end

    function [ndays, nbins] = getEarliestSustainedAnomaly( prec_bins, bin_size )
        %GETEARLIESTSUSTAINEDANOMALY Returns the earliest time that an anomaly
        %occurred before an eruption and was sustained unti the eruption.
        %Answer is returned in number of days and number of bins before
        %eruption. If there was no anomaly immediately befor the eruption, the
        %result is NaN.
        
        for i = 1:numel(prec_bins)
        
        
        % If there was an anomaly before the eruption, find out the time of the
        % earliest sustained anomaly
        if ~isempty(prec_bins{i}) && prec_bins{i}(end) == 1
            
            diff_bins = diff(prec_bins{i}); % the time inbetween each anomaly
            earliest_sust_anomaly_idx = find(diff_bins~=-1,1,'last') +1; % the index of the last value that is not a sustained anomaly + 1 (+1 is so that it becomes the last value that IS a sustained anomaly
            if isempty(earliest_sust_anomaly_idx), earliest_sust_anomaly_idx = 1; end;
            nbins(i) = prec_bins{i}(earliest_sust_anomaly_idx); % number of bins before eruption of last sustained anomaly
            ndays(i) = nbins(i) * bin_size(i); % number of days before eruption of last sustained anomaly
            
            % If there was no anomaly before the eruption, return a result
            % of NaN.
        else
           
           nbins(i) = NaN;
           ndays(i) = NaN;
           
        end
       
        end % for
       
    end % getEarliestSustainedAnomaly


end