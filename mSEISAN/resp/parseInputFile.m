function O = parseInputFile(UI)
% PARSEINPUTFILE Parses user input from file
% This does not work yet!

%%

    % OUTPUT FORMAT
O.outtyp_str = UI.output_format;
switch upper(O.outtyp_str)
    
    case {'NO OUTPUT FILE','NONE'}
        O.outtyp = 0;
        % keep default values
        
    case 'SEISAN FAP'
        O.outtyp = 1;
        % keep default values
        
    case 'GSE2 FAP'
        O.outtyp = 3;
        O.GSE = true;
        
    case 'SEISAN PAZ'
        O.outyp = 2;
        O.PAZ = true;
        
    case 'GSE2 PAZ'
        O.outtyp = 4;
        O.PAZ = true;
        O.GSE = true;
        
    otherwise
        error(['''' O.outtyp_str ''' is not a recognized output type'])
        
end

    % SENSOR
O.gse_cal2_instype = UI.instrument_description;
O.SENTYPstr = UI.sensor_type; % none | seismometer | accelerometer | mechanical displacement seismometer (initially enumerated as 1, 2, 3, 4)
switch lower(O.SENTYPstr) % allow enumeration to still work
    case 'none'
        O.SENTYP = 1;
    case 'seismometer'
        O.SENTYP = 2;
    case 'acceleromter'
        O.SENTYP = 3;
    case 'mechanical displacement seismometer'
        O.SENTYP = 4;
    otherwise
        warning(['''' O.SENTYPstr ''' is not a recognized intsrument type. Value ''none'' is being used.'])
        O.SENTYP = 1;
end
O.PERIOD = UI.natural_period;
O.DAMPIN = UI.damping_ratio;
O.GENCON = UI.generator_constant; % default: 1
O.GAIN = UI.amplifier_gain;
O.REGAIN = UI.recording_media_gain;

    % DIGITIZER
O.gse_dig2_description = UI.digitizer_model;
O.gse_dig2_samprat = UI.digitizer_sample_rate;
O.gse_rate=O.gse_dig2_samprat; % not sure why this variable is renamed
O.gse_dig2_sensitivity = UI.digitizer_sensitivity;

    % FILTER
O.FFILT = UI.freq_poles(:,1); % originally an n-by-2 matrix of frequency and number of poles for each filter; negative poles for high pass
O.POLE = UI.freq_poles(:,2); % originally an n-by-2 matrix of frequency and number of poles for each filter; negative poles for high pass
O.NFILT = UI.nfilters;

    % RESPONSE
O.GSE = false; O.PAZ = false; % set default values
% Set PAZ and GSE to proper values based on user input of output format;
% also enumerates output format options for future use in code
O.RESTYP = 1; O.RESCOR = 0; % 1: Displacement, 2: Velocity, 3: Acceleration
if O.SENTYP > 1
    if ~O.PAZ
        %        read RESTYP
        if O.SENTYP == 2, O.RESCOR = O.RESTYP-1; end
        if O.SENTYP == 3, O.RESCOR = O.RESTYP-3; end
        if O.SENTYP == 4, O.RESCOR = O.RESTYP; end
    end
end
O.nresp = 0;


% Other things that are needed
O.GSEPAZSCALE = UI.paz_scale;
O.norm = UI.norm;
O.npol = UI.npol;
O.nzero = UI.nzero;
O.nresp = UI.nresp;

end