function [bc, t_checks] = calculateBetaForThisWindow( times, start, stop, ndays, background_N, background_T )
% CALCULATEBETAFORTHISWINDOW Calculates beta for a given beta background
% window
%
% ACTIONS (Description of Code)
% Defines the exact time windows over which to calculate beta.
% For a given beta background window, uses the start and stop to create
% ndays length bins that do not overlap over which to calcualte beta. The
% start and stop of the bins is calculated by working backwards from the
% start of the eruption. E.g., if an eruption occurs on day 97 and the bin
% size is 30 days, the bins start on days 8, 38, and 68.
% Result is the stair step graph.
% * NOTE - Only does 1 bin length at a time. I.e., if you want to test 30
% day, 60 day, and 90 day windows, you have to run this script 3 times.



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

end % calculateBetaForThisWindow
