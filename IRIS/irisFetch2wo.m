function output = irisFetch2wo(type, scnl, start, stop)
% IRISFETCH2WO Does the same thing as irisFetch.Traces except it takes in
% an scnl object, start date, and stop date as the input.
% SEE ALSO irisFetch

% @Jay Wellik, Michigan Tech/USGS-VDAP
% Written:        2014-Feb-2
% Last Updated:   2015-Nov-17


%% First, get the data from IRIS

    % get the traces from IRIS
    % see help irisFetch for details
traces = irisFetch.Traces(  get(scnl,'network'),...
                            get(scnl,'station'),...
                            get(scnl,'location'),...
                            get(scnl,'channel'),...
                            start,stop);
                        
%%

switch type
    
    case 'waveform'
        
        % turn the output from irisFetch.Traces from a structure to a waveform object
        wo = setAsWO(scnl, traces, start, stop);
        output = wo;
        
    case 'combined waveform'
        
        error('This option is not yet supported.')
        
    case 'structure'
        
        output = traces;
        
    otherwise
        
        error('I did not understand your input for type.')
        
end


%%

    function wo = setAsWO(scnl, traces, start, stop)
        
        for n = 1:length(traces)
            
            % Initialize waveform object
            wo(n) = waveform();
            
            % Set SCNL parameters
            wo(n) = set(wo(n),'network',get(scnl,'network'));
            wo(n) = set(wo(n),'station',get(scnl,'station'));
            wo(n) = set(wo(n),'channel',get(scnl,'channel'));
            wo(n) = set(wo(n),'location',get(scnl,'location'));
            
            % Set signal paremeters
            wo(n) = set(wo(n),'start',traces(n).startTime);
            wo(n) = set(wo(n),'data',traces(n).data);
            wo(n) = set(wo(n),'freq',traces(n).sampleRate);
            wo(n) = set(wo(n),'units','Counts');
            
            % Set extra parameters
            wo(n) = addfield(wo(n),'latitude',traces(n).latitude);
            wo(n) = addfield(wo(n),'longitude',traces(n).longitude);
            wo(n) = addfield(wo(n),'instrument',traces(n).instrument);
            
        end
        
    end

end
%% END