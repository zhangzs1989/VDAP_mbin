%% run_AKtriggered_routines

try
load(fullfile('~/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/data/',LOG.volcano_name{1},'trigger_original.mat'))
load(fullfile('~/Documents/MATLAB/VDAP_mbin/dataseries/UnitedStates_explosions/data/', LOG.volcano_name{1}, '/R0.mat'))
catch
end

if exist('R0', 'var')
    trig_plot_TARE(trigger, LOG.DATA(5).CAT, R0, LOG.DATA(5).E)
else
    trig_plot_TARE(trigger, LOG.DATA(5).CAT, [], LOG.DATA(5).E)
end