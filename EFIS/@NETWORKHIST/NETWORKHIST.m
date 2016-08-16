classdef NETWORKHIST
    %NETWORKHIST Holds information pertaining to the on, off, and quality
    %of a particular network through time.

    %%

    properties
    
        name;           % name for network
        volcanoes;      % volcanoes monitored by this network
        start;          % start of network history
        stop;           % stop of network history

        % for n different periods of network health
        date_range;     % n-by-2 matrix of start/stop pairs for each network health period
        status;         % n-by-1 vector of health status codes for each period in date_range

        instruments;    % instruments associated with this network
        
        % enumerated codes for network health
        OFF = -1;
        GAPPY = -0.2;
        NOISY = -0.1;
        HEALTHY = 1;

    end


    properties (Dependent)

        time_series_status;    % n-by-2 matrix of datenums ( xxx(:,1) ) and health status codes ( xxx(:,2) )

    end

%% GET FUNCTIONS


methods

    
    function val = get.time_series_status(obj)



    end


end

%% RETURN FUNCTIONS    

methods
    
    % returns a n-by-2 vector of start/stop times for network health
    % periods
    % uses the time series of network status to determine the ranges
    % user defines if the return is for healthy network times, off
    % times, etc.
    function val = getRangesFromTimeSeries(obj, status)
        
%         switch status
%             
%             case 'healthy'
%                 
%             case 'noisy'
%                 
%             case 'gappy'
%                 
%             case 'off'
%                 
%             case 'unhealthy'
%                 
%             otherwise
%                 
%         end
        
        
    end
    
end

%% STATIC METHODS

methods (Static)
    
    % combines individual time ranges that are separated by less than
    % max_gap
    function val = combineRanges(ranges, max_gap)
        
        
    end
    
end

end