function [beta_output] = run_betas(times, windows, ndays, background_type, iterations, per_thresh)
disp(mfilename('fullpath'))
%RUN_BETAS Calculates empirical beta and executes multiple runs of beta
% statistic given time windows to test.
%
% INPUT:
% TIMES - earthquake event times
% WINDOWS [n-by2 matrix of start/stop times] - the time periods over which it is valid to calculate beta and
% empirical beta (e.g., this might be the times where there is no eruptive
% activity and the network is healthy).
% seismicity
% NDAYS - n-ny-1 matrix of window lengths that you would like to test beta
% for
% BACKGROUND_TYPE {'all' | 'individual' | 'past'} -- see GETEMPIRICALBETA for
% more help
% ITERATIONS [double] - The number of iterations to use to calculate beta
% PER_THRESH [double] - 
% 
% OUTPUT:
% BETA_OUTPUT 
%     t_checks - time corresponding to each 'bc'
%     bc - consecutive beta value
%     start - start of window
%     stop - stop of window
%     bin_sizes - the same as ndays
%     Be - empirical beta
%     P - percent threshold



%% Empirical Beta

    % calculate empirical beta value using all events in the background catalog
[Be, P, backT, backN] = getBetaEmpirical( background_type, times, windows, ndays, iterations, per_thresh );
[beta_output] = getMovingBeta( times, windows, ndays, Be, P, backT, backN );




end