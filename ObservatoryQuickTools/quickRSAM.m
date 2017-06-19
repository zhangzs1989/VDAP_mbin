function [ RSAM_OBJ, W ] = quickRSAM( ds, tag, tstart, tstop, method, ...
    sampling_period, varargin )
%QUICKRSAM Quickly produces RSAM from a given set of data
% This is a wrapper for GISMO/WAVEFORM2RSAM that allows you to compute RSAM
% directly from a datasource. The continuous data can also be filtered
% directly from this function. The results are returned as a waveform
% object, which is easier to use for the purposes of plotting, etc.
%
% INPUT
% + ds                  : datasource
% + tag                 : 1-by-n ChannelTag objects
% + tstart              :
% + tstop               :
% + method              : see WAVEFORM/WAVEFORM2RSAM for more help
% + sampling_period     : rsam interval in minutes 
% + (filt_obj)          : filters the waveform before plotting 
%
% OUTPUT
% + RSAM_OBJ - RSAM data stored as a waveform object
%
% SEE ALSO DATASOURCE WAVEFORM CHANNELTAG WAVEFORM/WAVEFORM2RSAM FILTEROBJECT WAVEFORM/FILTFILT

%% parse user input

% if there are extra input arguments
if numel(varargin) > 0
    
    % assume the first extra input argument is the filter object
    filterData = 1;
    filterobj = varargin{1};
    
else
    
    filterData = 0;
    
end

%% run

tstart = datenum(tstart);
tstop = datenum(tstop);

for s = 1:numel(tag)
    
    
    %% auto-preparation
        
    %     load('colors.mat')
    rsam = waveform(); rsam = set(rsam, 'ChannelTag', tag(s)); % initialize rsam object
    
    %% compute RSAM
    
    i = 0;
    t = tstart;
    while(t <= tstop)
        
        
        i = i+1;
        
        w = waveform(ds, tag(s), t, t+1);
        W(i) = w;
                
        if ~isempty(w)           
                
                if filterData && numel(get(w, 'data')) > 12 % waveform/filtfilt requires data length to be greater than 12 samples
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
            
        end
        
        % increment time
        t = t+1;
        close all
        clear w tmp_rsam
        
    end
    
    RSAM_OBJ(s) = rsam;
    
end

end