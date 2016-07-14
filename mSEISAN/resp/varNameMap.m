function OUT = varNameMap(IN)
% NOT CURRENTLY USED
% % VARNAMEMAP Converts var names from struct input in mRESP to the var names
% % used by MRESP.m to make calculations.
% % This feature is useful because the script in MRESP is copied almost
% % verbatim from the original Fortran code. The variable names are kept the
% % same in order to ease trouble shooting and modifications. The variable
% % names used in that part of the script, however, are not the most
% % intuitive variable names for a user. This function acts to convert the
% % user friendly variable names to the variable names actually used by the
% % response calculation script.
% %
% 
% %%
% 
% OUT.outtyp = IN.output_format;
% OUT.gse_cal2_instype = IN.sensor_description;
% OUT.SENTYP = IN.sensor_type;
% OUT.PERIOD = IN.natural_period;
% OUT.DAMPIN = IN.damping_ratio;
% OUT.GENCON = IN.generator_constant;
% OUT.GAIN = IN.amplifier_gain;
% OUT.REGAIN = IN.recording_media_gain;
% OUT.gse_dig2_description = IN.digitizer_model;
% OUT.gse_dig2_samprat = IN.dig_sample_rate;
% OUT.gse_dig2_sensitivity = IN.dig_sensitivity;
% OUT.NFILT = IN.nfilters;
% OUT.FFILT = IN.freq_poles(:, 1);
% OUT.POLE = IN.freq_poles(:, 2);
% OUT.RESTYP = IN.response_type;
% OUT.RESCOR = IN.rescor;
% OUT.GSEPAZSCALE = IN.paz_scale;


end