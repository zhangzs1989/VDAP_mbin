classdef respObj
    % RESPOBJ Currently experimenting with how to store these variables as
    % an object.
    
    % User Input / Human-readable variable names
    properties
        
        % OUTPUT
        output_format = ' ';
        output_filename = ' ';
        output_measuredValues = ' ';
        
        % SENSOR
        instrument_description = ' ';
        sensor_type = ' ';
        natural_period = 0;
        damping_ratio = 0;
        generator_constant = 0;
        
        % DIGITIZER
        digitizer_model = ' ';
        amplifier_gain =0 ;
        recording_media_gain = 0;
        paz_scale=1;
        digitizer_sample_rate = 0;
        digitizer_sensitivity = 1;
        
        % RESPONSE FILTERS
        nfilters = 7;
%         freq_poles = zeros(size(nfilters, 2));
        response_type = 'displacement' ; % 1: Displacement | 2: Velocity | 3: Acceleration
        nFIRfilterStages = 0; % not sure what this is or even if it's something that needs to be initialized
        
        
        amp1hz =0; % not sure what this does
        npol=0; % not sure what this is for
        nzero=0; % not sure what this is for
        norm=1; % not sure what this is for
        nresp = 0; % not sure what this is for
        % FFILT = zeros(7); POLE = zeros(7); % initialize seven filters % for i=1:7, FFILT(i)=0; POLE(i)=0; end
        
        
    end
    
    
    % SEISAN Defined variable names
    properties (SetAccess=private)
       
        % e.g.,
        OUTTYP      % OUTPUT TYPE
        SENTYP      % FLAG FOR TYPE OF SENSOR 0: NONE 1: SEISMOMETER 2: ACCELEROMETER (???)
       
        RESTYP
        
    end
    
    
    
    % SEISAN RESP Variables
    properties (Dependent)
        
        PAZ = false;        % FLAG IF PAZ CHOSEN
        
        
        GSE = false         % flag true if gse
        recal               % true if recalculation
        deffile             % text
        mainhead_text
        net_code            % network code
        no_net              % flag if net_code set
        
        RESCOR = 1;         %
        
        
    end

    
    % convert human-readable variable names to SEISAN variable names
    % These methods are completed automatically when the appropriate
    % human-readable variable name is filled.
    methods
        
        function OUTTYP = get.OUTTYP(obj)
            
           switch upper(obj.output_format)
               
               case {'NONE', 'NO OUTPUT FILE'}
                   
                   OUTTYP = 0;
                   
               case 'SEISAN FAP'
                   
                   OUTTYP = 1;
                   
               case 'SEISAN PAZ'
                   
                   OUTTYP = 2;
                   
               case 'GSE2 FAP'
                   
                   OUTTYP = 3;
                   
               case 'GSE2 PAZ'
                   
                   OUTTYP = 4;
                   
               otherwise
                   
           end
            
        end
        
        % FLAG FOR TYPE OF SENSOR 0: NONE 1: SEISMOMETER 2: ACCELEROMETER (???)
        function SENTYP = get.SENTYP(obj)
            
            switch upper(obj.sensor_type)
                
                case 'NONE'
                    
                    SENTYP = 1;
                    
                case 'SEISMOMETER'
                    
                    SENTYP = 2;
                    
                case 'ACCELEROMETER'
                    
                    SENTYP = 3;
                    
                case 'MECHANICAL DISPLACEMENT SEISMOMETER'
                    
                    SENTYP = 4;
                    
                otherwise
                    
                    % If the value for 'sensor_type' is not valid, it
                    % appears that the variable SENTYP is simply removed
                    % without any error being produced.
                    
            end
            
        end
        
        function PAZ = get.PAZ(obj)
            
            PAZ = false; % default value
            if (obj.OUTTYP == 2 || obj.OUTTYP == 4), PAZ = true; end
            
        end
        
        function GSE = get.GSE(obj)
            
            GSE = false; % default value
            if (obj.OUTTYP == 3 || obj.OUTTYP == 4), GSE = true; end
            
        end
        
        function RESTYP = get.RESTYP(obj)
            
            if obj.SENTYP > 1
                if ~obj.PAZ
                    
                    switch upper(obj.response_type)
                    
                        case 'DISPLACEMENT'
                        
                            RESTYP = 1;
                            
                        case 'VELOCITY'
                        
                            RESTYP = 2;
                            
                        case 'ACCELERATION'
                        
                            RESTYP = 3;
                            
                        otherwise
                        
                    end
                    
                end
            end
            
        end
        
        
        function RESCOR = get.RESCOR(obj)
            
            if obj.SENTYP > 1
                if ~obj.PAZ
                    
                    if obj.SENTYP == 2, RESCOR = obj.RESTYP - 1; end
                    if obj.SENTYP == 3, RESCOR = obj.RESTYP - 3; end
                    if obj.SENTYP == 4, RESCOR = obj.RESTYP; end
                    
                end
            end
            
        end
        

        
        
        
        
        
        
    end
    
    
end