function [ bc, t_checks ] = contBetaCalculation( times, start, stop, spacing, retro, ndays, background_N, background_T )
% CONTBETACALCULATION Calculates beta on overlapping beta windows
%
% INPUT
% - times - event times
% - start - start time of window
% - stop - stop time of window
% - spacing - time interval between each beta measurement
% - retro - 1 if start times work backwards from eruption (retrospective application), 0 if start times
% move forward (real-time application)
% - ndays - length of beta windows
% - background_N - number of events in background time period
% - background_T - length of time in background time period

%%

if isempty(times) % if there are no events provided, initialize the rest of the data as empty
    
    % M DEC 21 (JJW) - I think this section might need to go away.
    % Now that background is defined as some other time, we
    % don't want bc to be nan just because there are no times
    % in this window.
    % W AUG 17 (JJW) I think this section is unnecessary because if times
    % is empty, then getting a subset of the vector, as is done with
    % times_TA2, will also return an empty vector, and getting the length
    % of an empty vector will simply result in 0, which is an appropriate
    % input ot BETAS.
%     disp(['No events from ' datestr(start) ' to ' datestr(stop) '.'])
%     t_checks = start:ndays:stop;
%     bc(1:length(t_checks)) = nan;
    
else % else, move on to the actual calculations
    
    % background time and events are input variables
    T = background_T;
    N  = background_N;
    
    % "short term" time window
    Ta = ndays;
    
    %now check all ndays intervals prior to onset
    % adjust t_start to be rounded wrt ndays
%     spacing = 1
%     retro = 0
    start2 = start; % adjusted start time (gets adjusted if the study is retrospective
    if retro, start2 = stop - (floor((stop-start)/ndays))*ndays + 1; end
    t_checks = start2+ndays-1:spacing:stop; % stop times for each beta window to check
    nchecks=size(t_checks,2); % number of times to check beta
    bc(nchecks,1)=zeros; % initialize the beta values to 0 (! NOTE, this is not a good initialization value because beta can be negative)

    % calculate beta time series
    for j=1:nchecks % for each time to calculate beta
        
        times_TA2 = times(times >= t_checks(j)-ndays+1 & times <= t_checks(j)); % narrow catalog to events in the test window
        Na = length(times_TA2); % total number of events
        bc(j,1)=betas(Na,N,Ta,T); % beta value
        
    end
    
end

end % calculateBetaForThisWindow
