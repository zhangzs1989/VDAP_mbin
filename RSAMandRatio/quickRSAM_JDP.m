function [ RSAM_OBJ ] = quickRSAM_JDP( ds, tag, tstart, tstop, method, sampling_period, filterobj )
%QUICKRSAM Quickly produces RSAM from a given set of data
% This is a wrapper for WAVEFORM2RSAM that allows you to compute RSAM
% directly from a datasource. The continuous data can also be filtered
% directly from this function. The results are returned as a waveform
% object, which is easier to use for the purposes of plotting, etc.
%
% INPUT
% + ds - datasource
% + tag
% + method
% + sampling period (minutes)
% + filt_obj - filterobject
% + output_dir
%
% OUTPUT
% + RSAM_OBJ - RSAM data stored as a waveform object
%
% SEE ALSO DATASOURCE WAVEFORM CHANNELTAG WAVEFORM2RSAM FILTEROBJET WAVEFORM/FILTFILT

%% run
for s = 1:numel(tag)
    
    rsam = waveform(); rsam = set(rsam, 'ChannelTag', tag(s)); % initialize rsam object
    
    %% compute RSAM
    
    t = tstart;
    while(t < tstop)
        
        w = waveform(ds, tag(s), t, t+1);
%         w = load_waveformObject_VDAP(ds,tag(s),t,t+1,[]);
        w = demean(w);
        w = fillgaps(w, 0, NaN);
       
        if ~isempty(w)
                            
               if ~isnan(get(filterobj,'cutoff'))
                    w = filtfilt(filterobj, w);
               end
                
                sampling_period_sec = sampling_period*60;
                tmp_rsam = waveform2rsam(w, method, sampling_period_sec);
                tmp_wrsam = waveform();
                tmp_wrsam = set(tmp_wrsam, 'start', tmp_rsam.dnum(1));
                tmp_wrsam = set(tmp_wrsam, 'freq', 1/sampling_period_sec);
                tmp_wrsam = set(tmp_wrsam, 'ChannelTag', tag(s));
                tmp_wrsam = set(tmp_wrsam, 'data', tmp_rsam.data);
                
                rsam = combine([rsam tmp_wrsam]);
        else
            warning('empty waveform')
        end
        
        % increment time
        t = t+1;
        close all
        clear w tmp_rsam
        
    end
    
    RSAM(s) = rsam;
%     writeRSAM2file( RSAM(s), output_dir );
    
end
RSAM_OBJ = RSAM;
end