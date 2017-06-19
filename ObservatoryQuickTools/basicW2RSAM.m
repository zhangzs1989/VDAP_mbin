function R = basicW2RSAM( w, method, sampling_period )
%BASICW2RSAM Basic conversion of waveform object to RSAM stored in waveform
%object. Does not attempt to clean up the waveform object

sampling_period_sec = sampling_period*60;
rsam = waveform2rsam(w, method, sampling_period_sec);
wrsam = waveform();
wrsam = set(wrsam, 'start', rsam.dnum(1));
wrsam = set(wrsam, 'freq', 1/sampling_period_sec);
wrsam = set(wrsam, 'ChannelTag', get(w, 'ChannelTag'));
wrsam = set(wrsam, 'data', rsam.data);

R = wrsam;

end

