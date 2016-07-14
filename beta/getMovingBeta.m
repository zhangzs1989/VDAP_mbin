function [beta_output] = getMovingBeta( times, windows, ndays, Be, P, background_T, background_N)
disp(mfilename('fullpath'))
%% Moving Beta Window


for m = 1:size(windows,1); % test over start/stop time pair; need no. of rows to do this
    
    disp('---------------------------------------------------------------')
    disp('-- Calculating short term beta --------------------------------')
    
    start = windows(m,1); % start of test window
    stop = windows(m,2); % stop of test window
    
        % initialize the beginning time of each beta window and the beta
        % vale for that window
    beta_output(m).t_checks = [];
    beta_output(m).bc = [];
    
    
        % filter events to time window
    sub_times = times(times > start & times < stop);
    
        
    t_checks_max = start:1:stop; % start time for each beta window
    bcA = nan(size(t_checks_max,2),size(ndays,2)); % 
    t_checksA = nan(size(t_checks_max,2),size(ndays,2));
    
    for i = 1:length(ndays)
        
        disp(['Short term window length: ' num2str(ndays(i))])
        
        if stop-start > ndays(i) % only try to compute beta if the window time is longer than the short term beta window
            
            [bc, t_checks] = calculateBetaForThisWindow(sub_times, start, stop, ndays(i), background_N(i), background_T(i));
            
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

%% For each window


    function [bc, t_checks] = calculateBetaForThisWindow( times, start, stop, ndays, background_N, background_T )
        
        if isempty(times) % if there are no events provided, initialize the rest of the data as empty
            
                % M DEC 21 (JJW) - I think this section might need to go away.
                % Now that background is defined as some other time, we
                % don't want bc to be nan just because there are no times
                % in this window.
            disp(['No events from ' datestr(start) ' to ' datestr(stop) '.'])
            t_checks = start:ndays:stop;
            bc(1:length(t_checks)) = nan;
            
        else % else, move on to the actual calculations
            
                % background time and events are input variables
            T = background_T;	
            N  = background_N;

                % "short term" time window
            Ta = ndays;
                      
            %now check all ndays intervals prior to onset
            % adjust t_start to be rounded wrt ndays
            ndaysi = floor((stop-start)/ndays);
            t_start = stop - ndaysi*ndays;
            t_checks = t_start:ndays:stop;
            nchecks=size(t_checks,2);
            bc(nchecks,1)=zeros;
            
            
            for j=1:nchecks
                
                times_TA2 = times(times > t_checks(j) & times < t_checks(j)+ndays);
                Na = length(times_TA2);
                bc(j,1)=betas(Na,N,Ta,T);
                
            end
            
        end
        
    end

end