%% analyze LOG for Anomalies

repose = 1:35; % years
outlook = 1:10; % months

% LOG.SANOM(:) = struct([]);
for h = 1:height(LOG)
    
    SANOM = [];
    SANOM.start = LOG.DATA(1).tc(LOG.BETA(1).bv > LOG.BETA(1).be);
    SANOM.stop = SANOM.start + LOG.t_window(h,2);
    SANOM.dur_days = SANOM.stop - SANOM.start;
    SANOM.dur_bins = SANOM.dur_days ./  LOG.t_window(h,2);
    SANOM.bv = LOG.BETA(1).bv(LOG.BETA(1).bv > LOG.BETA(1).be);
%     SANOM.b_rat = (SANOM.bv - LOG.BETA(1).be) ./ LOG.BETA(1).be; % not
%     sue how this works actually
    LOG.SANOM(h) = SANOM;
    
    % Determine anomaly type
    % INPUTS -> eruptions, repose_vei, forecast_vei, anomalies, repose
    % variables, outlook variables
        % Anomaly Type
        % append 'Tp' 'Ta' 'Tr' to LOG
        % use this info to add SANOM.type
    SANOM.type = nan(size(SANOM.bv));

    
end