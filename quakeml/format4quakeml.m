function  s = format4quakeml(picks,event)

% return picks and event structure from readQuakeML function back to xml
% struct.
%

origin = returnorigin(event);
pick = returnpick(picks);

quake.origin = origin;
quake.pick = pick;
quake.magnitude.mag.value.Text = num2str(event.Magnitude);
quake.magnitude.type.Text = event.MagType;

s.q_colon_quakeml.eventParameters.event = quake;

end
%%
function origin = returnorigin(event)

origin.time.value.Text = datestr(event.DateTime,'yyyy-mm-ddTHH:MM:SS.FFFZ');
origin.latitude.value.Text = num2str(event.Latitude);
origin.longitude.value.Text = num2str(event.Longitude);
origin.depth.value.Text = num2str(event.Depth*1000);

end
%%
function pick = returnpick(picks)

for i=1:numel(picks)
    
    pick{1,i}.waveformID.Attributes.stationCode = picks(i).sta;
    pick{1,i}.time.value.Text = picks(i).time;
    pick{1,i}.waveformID.Attributes.channelCode = picks(i).chan;
    pick{1,i}.waveformID.Attributes.networkCode =  picks(i).net;
    pick{1,i}.phaseHint.Text = picks(i).phase;
    try
        pick{1,i}.time.uncertainty.Text = num2str(picks(i).uncert);
    end
    pick{1,i}.waveformID.Attributes.locationCode = picks(i).loc;

    pick{1,i}.Attributes.publicID = picks(i).publicID;
    
end

end

