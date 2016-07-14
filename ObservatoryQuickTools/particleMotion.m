function particleMotion( w_zne )
% PARTICLE_MOTION [IN DEVELOPMENT] Interactive plot of particle motions
% given a 3-by-1 vector of waveform objects.
% Particle motion figure that allows you to zoom and pan across a waveform
% and analyze particle motion.
%
% INPUT
% + w_zne - [3-by-1] vector of waveform objects in the order of Z, N, and E.
%


%{
% UPDATES
SEP 22 2015: Add plot labels
SEP 22 2015: Accept actual seismic data (stub)
SEP 22 2015: Include sample rate to get indices of seismic data associated with zoom limits
JUN 02 2016: Works with waveform object
JUN 03 2016: Include ability to pan

% WISH LIST
Work with heliPanel and clipboard
Be able to switch to spectogram (similar to working with heliPanel and
clipboard
If only a Z channel is provided, search for the existence of N and E channels.

%}

%% Stub data (trigometric)
%
% t = 1:100;
% z = 3*sin(t);
% e = 2*cos(t);
% n = -1*sin(t);

%% Stub data (seismic)
% 
% load('trace_data'); % from Iliamna, IVE_BH[Z,N,E]
% t = t-min(t)+1;
% sample_rate = 100;

%% Parse input data

if numel(w_zne)~=3, error('Input waveform object must have three components.'); end

    % channel order
w = w_zne;
z = get(w(1),'data');
n = get(w(2),'data');
e = get(w(3),'data');
sample_rate = get(w(1), 'freq');
t = get(w(1), 'start'):(1/sample_rate)/60/60/24:get(w(1), 'End'); % creates time vector to go with data
t = t(1:end-1);
t = 1:numel(z);

%% Initialize Figure

f = figure;


%% Plot data

    % Define space for waveforms & plot
sp(1) = subplot(2,3, 1:3);
sp(1).Tag = 'waveform';
% plotting components in reverse order allows Z channel to show up on top
% order is also relied on during zoom callback
eplot = plot(w(3), 'r'); hold on
nplot = plot(w(2), 'b'); hold on
vplot = plot(w(1), 'k', 'linewidth', 1.25);

legend(w(3:-1:1)) % creating the legend in reverse order makes the colors connect correctly

    % Define zoom axes and callbacks
wp_xlim = 1:length(z);
zh = zoom(sp(1));
zh.Motion = 'horizontal';
zh.ActionPostCallBack = {@waveformZoom, w};
zh.Enable = 'on';

    % Define pan and callbacks
ph = pan(f);
ph.Motion = 'horizontal';
ph.ActionPostCallBack = {@waveformZoom, w};
ph.Enable = 'on';

    % Define space for E/N particle motion & plot
sp(2) = subplot(2,3,4); plot(e(wp_xlim), n(wp_xlim), 'k');
sp(2).Tag = 'NE';
sp(2).Title.String = 'Horizontal';
xlabel('East'); ylabel('North');
axis square

    % Define space for E/Z particle motion & plot
sp(3) = subplot(2,3,5); plot(e(wp_xlim), z(wp_xlim), 'k');
sp(3).Tag = 'ZE';
sp(3).Title.String = 'Vertical';
xlabel('East'); ylabel('Vertical');
axis square

    % Define space for N/Z particle motion & plot
sp(4) = subplot(2,3,6); plot(n(wp_xlim), z(wp_xlim), 'k');
sp(4).Tag = 'ZN';
sp(4).Title.String = 'Vertical';
xlabel('North'); ylabel('Vertical');
axis square

    % Determine max and min values for consistent axes across all three
    % particle motion plots
pm_max = max(abs([sp(2:4).XLim sp(2:4).YLim])); % finds abs() of max particle motion from default plot

    % Make all particle motion axes the same
for n = 2:4
    sp(n).XLim(1) = -pm_max;
    sp(n).XLim(2) = pm_max;
    sp(n).YLim(1) = -pm_max;
    sp(n).YLim(2) = pm_max;
end

%% Callback Functions

    function waveformZoom(obj, eventdata, w)
        
        % obj - figure handle
        %      obj.Children(x) - an axis handle; enumerated in reverse
        %      order from when plotted
        %        e.g., obj.Children(4) is the waveform axis handle
        %      obj.Children(4).Children(j) - handle for a line
        %        e.g., obj.Children(4).Children(1) - the handle for the
        %        line for the last waveform data to be plotted
        % eventdata - axis handle for the axis that was clicked on
        %
        % NOTES:
        % waveform data are plotted with the x axis as counts, 1-N
        %
        
        sr = get(w(1), 'freq'); % get sample rate of waveform object
        
%         ndatapts = numel(obj.Children(4).Children(1).XData); % number of data points in original waveform trace (in just one trace)
        ndatapts = numel(get(w(1), 'data')); % number of data points in original waveform trace (in just one trace)
        
        
        %             % start of new time series window to end of new time series
        %             % window - expressed as t1:t2 (???)
        %         data_range = floor(eventdata.Axes.XLim(1)):ceil(eventdata.Axes.XLim(2));
        
        % start of new time series window to end of new time series
        % window
        % XLim values are in seconds, so we multiply by sample rate to
        % get the data range in samples. Use floor and ceil so that the
        % data range, which will be used as an index later, is in whole
        % numbers
        data_range = floor(eventdata.Axes.XLim(1)*sr):ceil(eventdata.Axes.XLim(2)*sr);
        
        % make sure datarange does not exceed data indices
        % this would happen if the beginning or end click was before
        % the start of the data or after the end of the data,
        % respectively
        if data_range(1) < 1, data_range = 1:data_range(end); end;
        if data_range(end) > ndatapts, data_range = data_range(1):ndatapts; end;
        
        
        %             % cut data from time series plot
        %             % You can't cut from the particle motion plots because they are
        %             % cut each time this callback is called, so after one zoom, the
        %             % axis might no longer contain all of the data
        %         new_e = obj.Children(4).Children(3).YData(data_range);
        %         new_n = obj.Children(4).Children(2).YData(data_range);
        %         new_z = obj.Children(4).Children(1).YData(data_range);
        
        % cut data from original (i.e., complete) waveform data
        % You can't cut from the particle motion plots because they are
        % cut each time this callback is called, so after one zoom, the
        % axis might no longer contain all of the data
        [d] = get(w, 'data'); % grabs trace data as 3-by-1 cell array where each cell is an n-by-1 vector of data points
        new_z = d{1}(data_range);
        new_n = d{2}(data_range);
        new_e = d{3}(data_range);
        
        
            % reset the particle motion data
            % (each one described as'Y/X plot')
            
            % obj.Children(3) represents E/N plot
        obj.Children(3).Children.XData = new_e;
        obj.Children(3).Children.YData = new_n; 
        
            % obj.Children(3) represents V/E plot
        obj.Children(2).Children.XData = new_e;
        obj.Children(2).Children.YData = new_z; 
        
            % obj.Children(3) represents V/N plot
        obj.Children(1).Children.XData = new_n;
        obj.Children(1).Children.YData = new_z;
        
    end


%     function waveformPan(obj, eventdata)
% 
%         
%     end


end