function [ picks ] = readQuakeML( quakemlFile )
% reads a quakeML file and returns a more easily accesible "picks" structure 
% J. PESICEK 2017
%   
s = xml2struct(quakemlFile); %downloaded from matlab exchange

picks = s.q_colon_quakeml.eventParameters.event;
numpicks = numel(picks.pick);

for i=1:numpicks
    tmp(i).sta   = picks.pick{1,i}.waveformID.Attributes.stationCode;
end

nsta = numel(unique(extractfield(tmp,'sta')));
npha = 2*nsta;

for i=1:numpicks

    pick(i).sta   = picks.pick{1,i}.waveformID.Attributes.stationCode;
    pick(i).phase = picks.pick{1,i}.phaseHint.Text;
    pick(i).time  = picks.pick{1,i}.time.value.Text;
    try
        pick(i).uncert= str2num(picks.pick{1,i}.time.uncertainty.Text);
    catch
        warning('could not find pick uncertainty')
    end
    pick(i).dn    = datenum(pick(i).time,'yyyy-mm-ddTHH:MM:SS.FFFZ');
    pick(i).chan = picks.pick{1,i}.waveformID.Attributes.channelCode;
    pick(i).net = picks.pick{1,i}.waveformID.Attributes.networkCode;
    pick(i).loc = picks.pick{1,i}.waveformID.Attributes.locationCode;

end

% if numel(pick) ~= npha
%     ip = (strcmp(extractfield(pick,'phase'),'P'));
%     is = (strcmp(extractfield(pick,'phase'),'S'));
%     
%     
% end

picks = pick;
