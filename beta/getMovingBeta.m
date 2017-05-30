function [beta_output] = getMovingBeta( times, windows, ndays, Be, P, background_T, background_N, spacing, retro)
%% GETMOVINGBETA Initializes the beta_output structure and some other features before beta is calculated
%
% INPUT
% times - [n-by-1 datenum] event times
% windows - [?] beta background windows
% ndays - [m-by-1] length of short term beta windows
% Be - [m-by-1] empirical beta values for each beta window length
% P - [m-bu-1] ?
% background_T - [t] length of background beta period
% background_N - [x] number of events in the background beta period
%
% ACTIONS (Explanation of Code)
% Loops through each "beta background" window
% Initializes the beta_output structure
% Determines the start and stop of each beta_output window
% Makes sure only catalog events from the beta_output time window are involved
% 

disp(mfilename('fullpath'))

%%


%%

for m = 1:size(windows,1); % test over start/stop time pair; need no. of rows to do this
    
    disp('---------------------------------------------------------------')
    disp(['     Calculating beta values at ' '<<volcano name>>' '...'])
    
    start = windows(m,1); % start of test window
    stop = windows(m,2); % stop of test window
    
    disp(['     from ' datestr(start, 'mmm dd, HH:MM:SS') ' to ' datestr(stop, 'mmm dd, HH:MM:SS') ])
    
    % initialize the beginning time of each beta window and the beta vale for that window
    beta_output(m).t_checks = [];
    beta_output(m).bc = [];
    
    
    % filter events to time window
    sub_times = times(times > start & times < stop);
    
    
    t_checks_max = start:1:stop; % start time for each beta window
    bcA = nan(size(t_checks_max,2),size(ndays,2)); %
    t_checksA = nan(size(t_checks_max,2),size(ndays,2));
    
    for i = 1:length(ndays)
        
        disp(['     for ' num2str(ndays(i)) ' day windows'])
        
        if stop-start > ndays(i) % only try to compute beta if the window time is longer than the short term beta window
            
%             [bc, t_checks] = calculateBetaForThisWindow(sub_times, start, stop, ndays(i), background_N(i), background_T(i));
            [bc, t_checks] = contBetaCalculation(sub_times, start, stop, spacing, retro, ndays(i), background_N(i), background_T(i)); % spacing and retro are hardcoded for right now
                        
            bcA(1:length(bc), i) = bc;
            t_checksA(1:length(t_checks),i) = t_checks;
            
        end
        
    end
    
    beta_output(m).t_checks = t_checksA;
    beta_output(m).bc = bcA;
    beta_output(m).start = start;
    beta_output(m).stop = stop;
    beta_output(m).bin_sizes = ndays;
    beta_output(m).Be = Be;
    beta_output(m).P = P;
    
    
end

end