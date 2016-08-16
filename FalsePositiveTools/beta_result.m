classdef beta_result
%BETA_RESULT Holds properties related to beta value time series
%   Each beta_result object is for a particular 'beta window'
%
%   Properties
%
%       start
%       stop
%       bin_sizes
%       Be
%       P
%       next_eruption
%       prev_eruption_end
%       prev_eruption_start
%
%       t_checks
%       bc
%       bin_mag
%
%   Dependent Properties
%
%       dur                 : duration of the beta window
%       next_eruption_disp  : txt version of next_eruption (datestr or str)
%       prev_eruption_end_disp : txt version of prev_eruption_end (datestr or str)
%       is_over_beta        : logical matrix; same size as bc
%       bcBe_ratio          : "strength of the beta anomaly"; same size as bc
%
%
%
%
    
    %%
    
    properties
        
        % general info about the entire window
        start = 0;
        stop = 0;
        bin_sizes;
        Be; % empirical beta value
        P; %
        next_eruption = NaN; % start of next eruption to occur from this volcano
        prev_eruption_end = datenum('January 1, 1975'); % end date of last eruption
        prev_eruption_start = datenum('January 1, 1975'); % start date of last eruption
        
        % time series info
        t_checks; % time stamps that correspond to bc; n-by-m matrix where n == number of samples and m == number of beta windows
        bc; % time series of beta values; n-by-m matrix (see above for details)
        bin_mag; % time series of cumulative magnitudes for each bin
        
    end
    
    %%
    
    properties (Dependent)
        
        % general info
        dur; % duration of the beta window
        next_eruption_disp; % text version of the next eruption (also displays 'No eruption...' if there is none)
        prev_eruption_end_disp; % text version of the next eruption (also displays 'No previous eruption...' if there is none)
        
        % time series info
        is_over_beta; % logical expression telling whether or not each beta value is above or below the anomaly
        bcBe_ratio; % ratio between measured beta value and empirical beta
        
        
        % individual anomalies
        n_anomalies; % number of anomalies for each bin size; same size as bin_sizes
        anomaly_dates; % datenum for each individual anomaly
        
        % Sustained anomalies - groups consecutive anomalies
        n_sust_anomalies; % number of sustained anomalies for each bin size; same size as bin_sizes
        sust_anomaly_dates;% [n-by-2] start & end pair for each sustained anomaly; where n is the number of sustained anomalies
        % start is the start time of the first anomaly in the set
        % end is the start time of the last anomaly in the set
        
        sust_anomaly_binlen; % length of each sustained anomaly in terms of # of bins
        sust_anomaly_daylen; % length of each sustained anomaly in terms of # of days
        sust_anomaly_precursor_days; % time to next eruption (measured from end of anomaly to start of next eruption)
        sust_anomaly_repose_days; % time since prev eruption (measured from end of prev eruption to start of anomaly)
        sust_max_bcBe; % largest bc/Be ratio during a sustained anomaly
        sust_mean_bcBe;% mean bc/Be ratio during a sustained anomaly
        
    end
    
    %% General methods
    
    methods
        
        
        %         function result = aggregate( input )
        %
        %             result.sust_anomaly_binlen = [];
        %
        %             for n = 1:numel(input)
        %
        %                 result.sust_anomaly_binlen = [result.sust_anomaly_binlen input(n).sust_anomaly_binlen{1}];
        %
        %
        %             end
        %
        %         end
        
        % Not sure what to do about this
        function val = hasdata(obj)
            
            val = true;
            if isempty(obj(1).t_checks), beta_result; val = false; end;
            
        end
        
    end
    
    %% functions for dependent properties
    
    methods
        
        % constructor class that changes a structure of beta output data to
        % an object. This is based on Jeremy and Jay's current design of
        % the beta_output structure
        function obj = beta_result( varargin )
            
            if nargin == 0
                % create an empty class
                
            else
                % assume the input is a beta_structure
                input = varargin{1};
                
                obj.t_checks = input.t_checks;
                obj.bc = input.bc;
                obj.start = input.start;
                obj.stop = input.stop;
                obj.bin_sizes = input.bin_sizes;
                obj.Be = input.Be; % empirical beta value
                obj.P = input.P; %
                obj.next_eruption = input.next_eruption;
                obj.prev_eruption_end = input.prev_eruption_end;
                obj.bin_mag = input.bin_mag;
                
            end
            
        end
        
    end
    
    %% general info
    
    methods
        
        % duration of the beta window
        function val = get.dur(obj)
            
            val = obj.stop - obj.start;
            
        end
                
    end
    
    %% SET FUNCTIONS
    
    methods
        
        % Uses a series of ERUPTION objects to set the next eruption for a
        % given beta result object
        function obj = setNextEruption(obj, E)
            
            E = chron(E); % make sure eruptions are in chronological order
            
            this_stop = obj.stop; % stop of this beta result window
            eruption_starts = get(E, 'start'); % starts of eruptions
            
            obj.next_eruption = eruption_starts(find(eruption_starts>=this_stop,1));
            
        end
        
        % Uses a series of ERUPTION objects to set the previous eruption for a
        % given beta result object
        function obj = setPrevEruptionEnd(obj, E)
            
            E = chron(E); % make sure eruptions are in chronological order
            
            this_start = obj.start; % start of this beta result window
            eruption_stops = get(E, 'stop'); % stops of eruptions
            
            obj.prev_eruption_end = eruption_stops(find(eruption_stops<=this_start,1,'last'));
            
        end
        
        % Uses a series of ERUPTION objects to set the previous eruption for a
        % given beta result object
        function obj = setPrevEruptionStart(obj, E)
            
            E = chron(E); % make sure eruptions are in chronological order
            
            this_start = obj.start; % start of this beta result window
            eruption_starts = get(E, 'start'); % stops of eruptions
            
            obj.prev_eruption_end = eruption_starts(find(eruption_starts<=this_start,1,'last'));
            
        end
        
        
        % Uses a series of ERUPTION objects to set both the previous and
        % next eruption for a given beta result object
        function obj = setEruptions(obj, E)
            
            obj = setPrevEruptionEnd(obj, E);
            obj = setNextEruption(obj, E);
            
        end
        
    end
    
    %% anomaly related functions
    
    methods
        
        % logic matrix corresponding to bc; tells whether or not the beta
        % value is above the threshold
        function val = get.is_over_beta(obj)
            
            Be_matrix = repmat(obj.Be, size(obj.bc,1), 1); % repeats the row vector of Be values for n rows so that it is same size as bc matrix; allows you to vectorize operations later
            %     bin_size_mat = repmat(bin_sizes, size(bc,1), 1); % see comment from line above
            
            % create vectors that identify:
            % is_over_beta : whether the beta value for each t_check is anomalous or not
            % dev_from_beta : the percent which the beta value differs from beta empirical
            val = obj.bc > Be_matrix;
            %             bcBe_ratio = bc./Be_matrix;
            
        end
        
        % ratio of measured beta value to empirical beta value
        function val = get.bcBe_ratio(obj)
            
            Be_matrix = repmat(obj.Be, size(obj.bc,1), 1); % repeats the row vector of Be values for n rows so that it is same size as bc matrix; allows you to vectorize operations later
            %     bin_size_mat = repmat(bin_sizes, size(bc,1), 1); % see comment from line above
            val = obj.bc ./ Be_matrix;
            
        end
        
        % cell array of dates of all beta anomalies for each bin size
        function val = get.anomaly_dates(obj)
            
            for n = 1:numel(obj.bin_sizes)
                val{n} = obj.t_checks(obj.is_over_beta(:,n)==1, n);
            end
            
        end
        
        % number of anomalies recorded for each bin size
        function val = get.n_anomalies(obj)
            
            for n = 1:numel(obj.bin_sizes)
                val(n) = numel(obj.anomaly_dates{n});
            end
            
        end
        
        % cell array of dates for all continous anomalies; i.e., if there
        % are two anomalies in anomaly_dates that happen consecutively, the
        % second date is removed from this set of information
        function val = get.sust_anomaly_dates(obj)
            
            for n = 1:numel(obj.bin_sizes)
                
                if obj.n_anomalies(n) <= 1
                    val{n} = [obj.anomaly_dates{n} obj.anomaly_dates{n}];
                    
                else
                    d = diff(obj.anomaly_dates{n});
                    s = obj.anomaly_dates{n}([0; d]~=obj.bin_sizes(n));
                    e = obj.anomaly_dates{n}([d; 0]~=obj.bin_sizes(n));
                    val{n} = [s e];
                    
                end
                
            end
            
        end
        
        % number of sustained anomalies for each bin size
        function val = get.n_sust_anomalies(obj)
            
            val = obj.n_anomalies; % should this be initialized or not?
            if hasdata(obj)
                
                for n = 1:numel(obj.sust_anomaly_dates)
                    val(n) = size(obj.sust_anomaly_dates{n}, 1);
                end
                
            end
        end
        
        % number of days between sustained anomaly and an eruption (i.e.,
        % number of precursory days). If the anomaly occurred immediately
        % before the eruption, this value is 0; otherwise, this value is
        % the number of days between the false positive and the eruption.
        % Time is measured as the time between the end of the anomaly
        % window and the start of the eruption.
        function val = get.sust_anomaly_precursor_days(obj)
            
            for b = 1:numel(obj.bin_sizes)
                
                if ~isnan(obj.next_eruption)
                    val{b} = obj.next_eruption - obj.sust_anomaly_dates{b}(:,2) - obj.bin_sizes(b); % subtract bin_size so that time is measured from the end of the anomaly window (:,2) to the start of the eruption
                else
                    val{b} = nan(size(obj.sust_anomaly_dates{b}(:,2)));
                end
            end
            
        end
        
        % number of days between end of last eruption and the start of the anomaly
        function val = get.sust_anomaly_repose_days(obj)
            
            for b = 1:numel(obj.bin_sizes)
                
                val{b} = nan(size(obj.sust_anomaly_precursor_days{b}));
                
                if ~isnan(obj.prev_eruption_end)
                    
                    val{b} = obj.sust_anomaly_dates{b}(:,1) - obj.prev_eruption_end;
                    
                else
                    
                    val{b} = nan(size(obj.sust_anomaly_precursor_days{b}));
                    
                end
                
            end
            
        end
        
        % duration of the sustained anomaly
        function val = get.sust_anomaly_binlen(obj)
            
            for b = 1:numel(obj.bin_sizes)
                
                anom_dates = obj.sust_anomaly_dates{b};
                
                if ~isempty(anom_dates)
                    val{b} = (anom_dates(:,2) - anom_dates(:,1) + obj.bin_sizes(b)) / obj.bin_sizes(b);
                else
                    val{b} = [];
                end
                
            end
            
        end
        
        % length of sustained anomaly in terms of # of days
        function val = get.sust_anomaly_daylen(obj)
            
            for b = 1:numel(obj.bin_sizes)
                
                val{b} = obj.sust_anomaly_binlen{b} * obj.bin_sizes(b);
                
            end
            
        end
        
        % max bcBe ratio during a sustained anomaly
        function val = get.sust_max_bcBe(obj)
            
            for b = 1:numel(obj.bin_sizes)
                
                bc_ = obj.bc(:, b);
                t_ = obj.t_checks(:, b);
                anom_dates = obj.sust_anomaly_dates{b};
                max_bc = []; % initialize the value in case there are no anomalies
                
                for n = 1:size(anom_dates,1)
                    
                    all_bc = bc_(t_ >= anom_dates(n,1) & t_ <= anom_dates(n,2));
                    max_bc(n) = max(all_bc);
                    
                end
                
                val{b} = max_bc;
                clear max_bc
                
            end
            
        end
        
        % mean bcBe ratio during a sustained anomaly
        function val = get.sust_mean_bcBe(obj)
            
            for b = 1:numel(obj.bin_sizes)
                
                bc_ = obj.bc(:, b);
                t_ = obj.t_checks(:, b);
                anom_dates = obj.sust_anomaly_dates{b};
                mean_bc = []; % initialize the value in case there are no anomalies
                
                for n = 1:size(anom_dates,1)
                    
                    all_bc = bc_(t_ >= anom_dates(n,1) & t_ <= anom_dates(n,2));
                    mean_bc(n) = mean(all_bc);
                    
                end
                
                val{b} = mean_bc;
                clear mean_bc
                
            end
            
        end
        
    end % anomaly related methods
    
    %% display functions
    
    methods
        
        % overloaded disp function for the class
        function disp(obj, varargin)
            
            
            for o = numel(obj)
                if ~isempty(obj(o))
                    
                    display(' ')
                    %                     display(['     Beta Window: ' datestr(obj(o).start) ' to ' datestr(obj(o).stop)])
                    display(['     Beta Window: '])
                    display(['     ( ' num2str(obj(o).dur) ' days == ' num2str(obj(o).dur/30) ' months == ' num2str(obj(o).dur/365) ' years )'])
                    display(['          prev_eruption_end   : ' obj(o).prev_eruption_end_disp])
                    display(['        start: ' datestr(obj(o).start)])
                    display(['        stop : ' datestr(obj(o).stop)])
                    display(['          next_eruption       : ' obj(o).next_eruption_disp])
                    fprintf('\n')
                    fprintf('        bin_size\t| (n)\t| Be\t| P     \t| n_anomalies\t| n_sust_anomalies\n')
                    fprintf('        ----------------------------------------------------------------------------------\n')
                    for i = 1:numel(obj(o).bin_sizes)
                        % e.g., "        30 days		| 5769	| 4.50	|  7.21	"
                        fprintf('        %i days\t\t| %i\t| %5.2f\t| % 7.2f\t| %i       \t| %i\t\n', obj(o).bin_sizes(i), numel(obj(o).t_checks(:,i)), obj(o).Be(i), obj(o).P(i), obj(o).n_anomalies(i), obj(o).n_sust_anomalies(i))
                    end
                    fprintf('        ----------------------------------------------------------------------------------\n')
                    fprintf('        * n -> number of beta samples')
                    display(' ')
                    display(' ')
                    
                end
            end
            
        end % disp
        
        %Display information about anomalies, their timings, and when
        %they occur relative to eruptions
        function anomalyReport(obj)
            
                        
        end % anomalyReport
            
                % next eruption datestr or message that says there is no eruption
        % (this is for display purporses)
        function val = get.next_eruption_disp(obj)
            
            if isnan(obj.next_eruption)
                
                val = 'NaN (No future eruption in database.)';
                
            else
                
                val = datestr(obj.next_eruption);
                
            end
            
        end
        
        % previous eruption datestr or message that says there was
        % no prev eruption
        % (this is for display purporses)
        function val = get.prev_eruption_end_disp(obj)
            
            if obj.prev_eruption_end==datenum('January 1, 1975')
                
                val = ['Default = ' datestr(obj.prev_eruption_end) ' (No previous eruption in database.)'];
                
            elseif isnan(obj.prev_eruption_end)
                val = 'NaN (No previous eruption in database.)';
                
            else
                
                val = datestr(obj.prev_eruption_end);
                
            end
            
        end
    
    end % methods
    
end

