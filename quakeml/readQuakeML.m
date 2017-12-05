function [ s, varargout ] = readQuakeML( quakemlFile,varargin )

% reads a quakeML file and returns a more easily accesible "picks" structure
% and/or an "event" structure if it exists in file;
% J. PESICEK 2017
%
if ~exist(quakemlFile,'file')==2 % single quakeml file input
    error('file DNE')
end

if nargin == 1
    
    if nargout ~=3
        error('requires 3 outputs')
    end
    
    s = xml2struct(quakemlFile); %downloaded from matlab exchange
    quake = s.q_colon_quakeml.eventParameters.event;
    
    varargout{1} = returnpicks(quake);
    varargout{2} = returnevent(quake);
    
elseif nargin == 2
    
    if nargout ~=2
        error('requires 2 outputs')
    end
    
    s = xml2struct(quakemlFile); %downloaded from matlab exchange
    quake = s.q_colon_quakeml.eventParameters.event;
    
    switch varargin{1}
        
        case 'picks'
            
            varargout{1} = returnpicks(quake);
            
        case 'origin'
            
            varargout{1} = returnevent(quake);
            
        otherwise
            
            error('option not supported')
            
    end
    
elseif nargin == 3 % return picks and OT
    
    if nargout ~=3
        error('requires 3 outputs')
    end
    
    s = xml2struct(quakemlFile); %downloaded from matlab exchange
    quake = s.q_colon_quakeml.eventParameters.event;
    
    switch varargin{1}
        
        case 'picks'
            
            varargout{1} = returnpicks(quake);
            
        case 'origin'
            
            varargout{1} = returnevent(quake);
            
        otherwise
            
            error('option not supported')
            
    end
    
    switch varargin{2}
        
        case 'picks'
            
            varargout{2} = returnpicks(quake);
            
        case 'origin'
            
            varargout{2} = returnevent(quake);
            
        otherwise
            
            error('option not supported')
            
    end
    
elseif nargin > 3
    
    error('option not supported')
end

end
%%
function picks = returnpicks(quake)

numpicks = numel(quake.pick);
for i=1:numpicks
    tmp(i).sta   = quake.pick{1,i}.waveformID.Attributes.stationCode;
end

for i=1:numpicks
    
    pick(i).sta   = quake.pick{1,i}.waveformID.Attributes.stationCode;
    pick(i).time  = quake.pick{1,i}.time.value.Text;
    pick(i).chan = quake.pick{1,i}.waveformID.Attributes.channelCode;
    pick(i).net = quake.pick{1,i}.waveformID.Attributes.networkCode;
    try
        pick(i).phase = quake.pick{1,i}.phaseHint.Text;
    catch
        warning(['could not find phase hint for ',pick(i).sta])
    end
    try
        pick(i).uncert= str2double(quake.pick{1,i}.time.uncertainty.Text);
    catch
        warning(['could not find pick uncertainty for ',pick(i).sta])
    end
    try
        pick(i).dn = datenum(pick(i).time,'yyyy-mm-ddTHH:MM:SS.FFFZ');
    catch
        pick(i).dn = datenum(pick(i).time,'yyyy-mm-ddTHH:MM:SSZ');
    end
    try
        pick(i).loc = quake.pick{1,i}.waveformID.Attributes.locationCode;
    catch
        warning('No location code provided, using default')
        pick(i).loc = '--';
    end
    try
        pick(i).polarity = quake.pick{1,i}.polarity.Text;
    catch
        pick(i).polarity = '?';        
    end
        
    pick(i).publicID = quake.pick{1,i}.Attributes.publicID;

end

picks = pick;

end
%%
function event = returnevent(quake)

try
    origin = quake.origin;
    dt = origin.time.value.Text;
    event.DateTime = datestr(datenum(dt,'yyyy-mm-ddTHH:MM:SS.FFFZ'));
    event.Latitude = str2double(origin.latitude.value.Text);
    event.Longitude = str2double(origin.longitude.value.Text);
    event.Depth = str2double(origin.depth.value.Text)/1000;
    try
        event.Magnitude = str2double(quake.magnitude.mag.value.Text);
        event.MagType = quake.magnitude.type.Text;
    catch
        event.Magnitude = [];
        event.MagType = [];
    end
    % TODO: there are more fields to add...
catch
    disp('missing event data')
    event = [];
end

end