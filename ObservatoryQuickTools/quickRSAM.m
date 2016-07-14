function [ RSAM_OBJ ] = quickRSAM( ds, tag, tstart, tstop, method, sampling_period, filterobj )
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
% + sampling period
% + filt_obj - filterobject
% + output_dir
%
% OUTPUT
% + RSAM_OBJ - RSAM data stored as a waveform object
%
% SEE ALSO DATASOURCE WAVEFORM CHANNELTAG WAVEFORM2RSAM FILTEROBJET WAVEFORM/FILTFILT

%% run

for s = 1:numel(tag)
    
    
    %% auto-preparation
    
    output_dir = [base_dir tag(s).string '/'];
    mkdir(base_dir);
    mkdir(output_dir);
    
    %     load('colors.mat')
    rsam = waveform(); rsam = set(rsam, 'ChannelTag', tag(s)); % initialize rsam object
    % w_all = waveform(); w_all = set(w_all, 'ChannelTag', tag); % initialize waveform object for all data
    
    %% compute RSAM
    
    t = tstart;
    while(t <= tstop)
        
        w = waveform(ds, tag(s), t, t+1);
        
        w = demean(w);
        w = fillgaps(w, 0, NaN);
        
        if ~isempty(w)
            
            if ~isempty(w)
                
                w = filtfilt(filterobj, w);
                
                
                sampling_period_sec = sampling_period*60;
                tmp_rsam = waveform2rsam(w, method, sampling_period_sec);
                tmp_wrsam = waveform();
                tmp_wrsam = set(tmp_wrsam, 'start', tmp_rsam.dnum(1));
                tmp_wrsam = set(tmp_wrsam, 'freq', 1/sampling_period_sec);
                tmp_wrsam = set(tmp_wrsam, 'ChannelTag', tag(s));
                tmp_wrsam = set(tmp_wrsam, 'data', tmp_rsam.data);
                
                rsam = combine([rsam tmp_wrsam]);

            end
            
        end
        
        % increment time
        t = t+1;
        close all
        clear w tmp_rsam
        
    end
    
    RSAM(s) = rsam;
    %     writeRSAM2file( RSAM(s), output_dir );
    
end

end