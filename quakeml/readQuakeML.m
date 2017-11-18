function [ picks, varargout ] = readQuakeML( quakemlFile )

% reads a quakeML file and returns a more easily accesible "picks" structure
% and optionally an event structure if it exists in file;
% J. PESICEK 2017
%
s = xml2struct(quakemlFile); %downloaded from matlab exchange

quake = s.q_colon_quakeml.eventParameters.event;
numpicks = numel(quake.pick);

for i=1:numpicks
    tmp(i).sta   = quake.pick{1,i}.waveformID.Attributes.stationCode;
end

nsta = numel(unique(extractfield(tmp,'sta')));
npha = 2*nsta;

for i=1:numpicks
    
    pick(i).sta   = quake.pick{1,i}.waveformID.Attributes.stationCode;
    pick(i).phase = quake.pick{1,i}.phaseHint.Text;
    pick(i).time  = quake.pick{1,i}.time.value.Text;
    try
        pick(i).uncert= str2num(quake.pick{1,i}.time.uncertainty.Text);
    catch
        warning('could not find pick uncertainty')
    end
    pick(i).dn    = datenum(pick(i).time,'yyyy-mm-ddTHH:MM:SS.FFFZ');
    pick(i).chan = quake.pick{1,i}.waveformID.Attributes.channelCode;
    pick(i).net = quake.pick{1,i}.waveformID.Attributes.networkCode;
    try
        pick(i).loc = quake.pick{1,i}.waveformID.Attributes.locationCode;
    catch
        warning('No location code provided, using default')
        pick(i).loc = '--';
    end
    
end

picks = pick;

if nargout == 2
    event = [];
    
    try
        origin = quake.origin;
        dt = origin.time.value.Text;
        event.DateTime = datestr(datenum(dt,'yyyy-mm-ddTHH:MM:SS.FFFZ'));
        event.Latitude = str2double(origin.latitude.value.Text);
        event.Longitude = str2double(origin.longitude.value.Text);
        event.Depth = str2double(origin.depth.value.Text)/1000;
        event.Magnitude = str2double(quake.magnitude.mag.value.Text);
        event.MagType = quake.magnitude.type.Text;
        % TODO: there are more fields to add...
    catch
        disp('missing event data')
    end
    varargout{1} = event;
    
elseif nargout > 2
    error('bad outputs')
end

end