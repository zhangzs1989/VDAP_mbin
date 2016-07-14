%% VDAP instrument response

%%

    % VDAP instrument specifics

instrument_type = 'L-4'; % { 'L-4' | 'L-22' }
output_device = 'PSN/Webstronics'; % { 'National instrument' | 'PSN/Webtronics' }
output_device_range = 10; % plus or minus, { 5 | 10 }
mcvco_gain = 60; % dB
telemetry_gain = -4.9; % db
vco_type = {'McVCO'};
discriminator_type = {'Mc8', 'J120D'};

%% RESP input


    % Properties needed to determine instrument response
    % Populated with default values

i.sensor_type = 'seismometer'; % none | seismometer | accelerometer | mechanical displacement seismometer
i.instrument_type
i.natural_period = 1;
i.damping_ratio = 0.8;
i.generator_constant = NaN;
i.recording_media_gain = NaN;
i.digitizer_sample_rate = 100;
i.digitizer_model = 'PSN, +/-10v range'; % just a name
i.amplifier_gain = NaN;
i.filt_freqpoles = NaN; % n-by-2 matrix of frequency and number of poles for each filter; negative poles for high pass
i.nfilters = size(i.filt_freqpoles,1);
i.output_format = 'GSE2 PAZ'; % SEISAN FAP | SEISAN PAZ | GSE2 FAP | GSE2 PAZ



%% parse VDAP input

% Many of the settings depend on the VDAP-specific setup. Here are a few of
% the parameters that depend on those setups.

    % Natural Period and Generator Constant
switch upper(i.instrument_type)
    
    case 'L-4'
        
        i.natural_period = 1;
        i.generator_constant = 100;

        
    case 'L-22'
        
        i.natural_period = 0.5;
        i.generator_constant = 25;

        
    otherwise
        
end


    % recording_media_gain
switch upper(output_device)
    
    case 'NATIONAL INSTRUMENT'
        
        i.recording_media_gain = 819.6;
        
        
    case 'PSN/WEBSTRONICS'
        
        
        switch output_device_range
            
            case 5
                
                i.recording_media_gain = 6553.6;
                
            case 10
                
                i.recording_media_gain = 3276.8;

        end
        
    otherwise
  
end

    % amplifier gain
i.amplifier_gain = mcvco_gain + telemetry_gain; % dB


    % filter frequency and poles
i.filt_freqpoles = [NaN NaN];
for n = 1:numel(vco_discriminator_type)
    
    type = vco_discriminator_type{n};
    display(['Adding filter for ' type '...']);
    
    switch upper(vco_discriminator_type{n})
        
        case 'MCVCO'
            
            i.filt_freqpoles = [i.filt_freqpoles; 30 4];
            
        case 'MC8, J120D'
            
            i.filt_freqpoles = [i.filt_freqpoles; 20 4];
            
        case 'MC8 HIGH-PASS'
            
            i.filt_freqpoles = [i.filt_freqpoles; 0.1 1];
            
        case 'KINEMETRICS DM-2'
            
            i.filt_freqpoles = [a; 25.3];
            
            
        case 'VR-60 LOW-PASS'
            
            i.filt_freqpoles = [a; 35 4];
            
        otherwise
            
            
    end
    
end
i.filt_freqpoles = i.filt_freqpoles(2:end, :);
i.nfilters = size(i.filt_freqpoles,1);