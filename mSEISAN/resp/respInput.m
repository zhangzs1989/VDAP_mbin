function DEFAULT = respInput
% RESPINPUT Creates structure of default values for response input.

% Programmer's note:
% Structure uses user friendly variable names that can be converted to the
% SEISAN variable names used by RESP.m
%

%%

    % OUTPUT
DEFAULT.output_format = ' ';
DEFAULT.output_filename = ' ';
DEFAULT.output_measuredValues = ' ';

    % SENSOR
DEFAULT.instrument_description = ' ';
DEFAULT.sensor_type = ' ';
DEFAULT.natural_period = 0;
DEFAULT.damping_ratio = 0;
DEFAULT.generator_constant = 0;

    % DIGITIZER
DEFAULT.digitizer_model = ' ';
DEFAULT.amplifier_gain =0 ;
DEFAULT.recording_media_gain = 0;
DEFAULT.paz_scale=1;
DEFAULT.digitizer_sample_rate = 0;
DEFAULT.digitizer_sensitivity = 1;

    % RESPONSE FILTERS
DEFAULT.nfilters = 7;
DEFAULT.freq_poles = zeros(size(DEFAULT.nfilters, 2));
DEFAULT.response_type = 'displacement' ; % 1: Displacement | 2: Velocity | 3: Acceleration
DEFAULT.RESCOR = 0;
DEFAULT.nFIRfilterStages = 0; % not sure what this is or even if it's something that needs to be initialized


DEFAULT.amp1hz =0; % not sure what this does
DEFAULT.npol=0; % not sure what this is for
DEFAULT.nzero=0; % not sure what this is for
DEFAULT.norm=1; % not sure what this is for
DEFAULT.nresp = 0; % not sure what this is for 
% FFILT = zeros(7); POLE = zeros(7); % initialize seven filters % for i=1:7, FFILT(i)=0; POLE(i)=0; end



end