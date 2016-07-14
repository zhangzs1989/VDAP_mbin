% stub file for typical VDAP sensor/digitizer setup (to be used in testing of resp.m)

display('User input for SEISANs RESP module given a typical VDAP instrument')

SKNdig = respInput;

SKNdig.output_format = 'GSE2 PAZ'; % { SEISAN FAP | SEISAN PAZ | GSE2 FAP | GSE2 PAZ }
SKNdig.sensor_type = 'seismometer'; % {'none', 'seismometer' | 'accelerometer' | 'mechanical displacement seismometer'}
SKNdig.natural_period = 1;
SKNdig.damping_ratio = 0.8;
SKNdig.generator_constant = 100;
SKNdig.instrument_description = 'L-4';
SKNdig.recording_media_gain = 3276.8;
SKNdig.digitizer_sample_rate = 100;
SKNdig.digitizer_model = 'PSN, +/-10v range'; % just a name
SKNdig.amplifier_gain = 61;
SKNdig.nfilters = 2;
SKNdig.freq_poles = [30 4; 20 4]; % n-by-2 matrix of frequency and number of poles for each filter; negative poles for high pass
SKNdig.nFIRfilterStages = 0;

SKNdig


%%

SKNdrum.output_format = 'none'; % { SEISAN FAP | SEISAN PAZ | GSE2 FAP | GSE2 PAZ }
SKNdrum.sensor_type = 'seismometer'; % {'none', 'seismometer' | 'accelerometer' | 'mechanical displacement seismometer'}
SKNdrum.natural_period = 1;
SKNdrum.damping_ratio = 0.8;
SKNdrum.generator_constant = 100;
% SKNdrum.instrument_description = 'L-4';
SKNdrum.recording_media_gain = 20;
SKNdrum.digitizer_sample_rate = 100;
% SKNdrum.digitizer_model = 'PSN, +/-10v range'; % just a name
SKNdrum.amplifier_gain = 61;
SKNdrum.nfilters = 2;
SKNdrum.freq_poles = [30 4; 20 4]; % n-by-2 matrix of frequency and number of poles for each filter; negative poles for high pass
SKNdrum.response_type = 'displacement';


SKNdrum


%%

cmg6td.output_format = 'GSE2 PAZ'; % { SEISAN FAP | SEISAN PAZ | GSE2 FAP | GSE2 PAZ }
cmg6td.sensor_type = 'none'; % {'none', 'seismometer' | 'accelerometer' | 'mechanical displacement seismometer'}
% cmg6td.natural_period = 1;
% cmg6td.damping_ratio = 0.8;
% cmg6td.generator_constant = 100;
% cmg6td.instrument_description = 'L-4';
cmg6td.recording_media_gain = 1;
cmg6td.digitizer_sample_rate = 50;
cmg6td.digitizer_model = 'cmg-6td'; % just a name
cmg6td.amplifier_gain = 61;
cmg6td.nfilters = 2;
cmg6td.freq_poles = [30 4; 20 4]; % n-by-2 matrix of frequency and number of poles for each filter; negative poles for high pass
cmg6td.response_type = 'displacement';
cmg6td.nFIRfilterStages = 0;


cmg6td

