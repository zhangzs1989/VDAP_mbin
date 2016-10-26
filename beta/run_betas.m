function [beta_output] = run_betas(times, windows, background_type, params, vinfo)

disp(mfilename('fullpath'))
%RUN_BETAS Calculates empirical beta and executes multiple runs of beta
% statistic given time windows to test.
%
% INPUT:
% TIMES - earthquake event times
% WINDOWS [n-by-2 matrix of start/stop times] - the time periods over which.
%  it is valid to calculate beta and empirical beta (e.g., this might be 
%  the times where there is no eruptive
%  activity and the network is healthy).
% NDAYS - n-ny-1 matrix of window lengths that you would like to test beta
% BACKGROUND_TYPE {'all' | 'individual' | 'past'} -- see GETEMPIRICALBETA for
%   more help
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
[Be, P, backT, backN] = getBetaEmpirical( background_type, times, windows, params, vinfo);
[beta_output] = getMovingBeta( times, windows, params.ndays_all, Be, P, backT, backN, params.spacing, params.retro );




end