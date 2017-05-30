function ro = rsam2obj( r )
%% Converts GISMO RSAM structure to waveform object)

ro = waveform();
ro = set(ro, 'data', r.data);
ro = set(ro, 'station', r.sta);
ro = set(ro, 'channel', r.chan);
ro = set(ro, 'start', r.snum);
ro = set(ro, 'freq', numel(r.data)/((r.enum - r.snum)*86400));


end