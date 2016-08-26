classdef ERUPTION
    %ERUPTION Stores information related to a specific eruptive episode
    
    %%
    
    properties
        
        volcano;            % volcano object associated with this eruption
        volcano_name;       % string volcano name - in case there is no associated object
        start;              % no specific definition
        stop;               % no specific definition
        max_vei;            %
        first_phreatic;     %
        first_magmatic;     %
        explosions;         % datenum vector of explosion times

        % temp fields used to hold info from Stephanie
        % eventually, this info should be stores in misc_fields
        forecastyn;
%         seismonitored;
        
        % future development should take advantage of this feature:
%         misc_fields;        % user defined fields; e.g., forecastyn, seismonitored, etc.
        
    end
    
    
%%

properties (Dependent)
    
    forecastyn_str;
    duration;
    
end

    
%% DISPLAY FUNCTIONS

methods
    
    function disp(obj)
        
        if numel(obj)>1
            
            display(' ')
            
            display('----------------------------------------------------')
            display(['Multiple (' num2str(numel(obj)) ') eruptions with common properties:'])
            display(['    start   : ' ])
            display(['    stop    : (duration)'])
            display(['    max_vei : ' ])
            display(' ')
            display(['    Info from Steph - '])
            display(['      forecastyn   : '])
            display(' ')
            
        else
            
            if ~isempty(obj.start)
                
                display(' ')
                display('----------------------------------------------------')
                display([' Eruption from ' upper(obj.volcano_name)])
                display(['    start   : ' datestr(obj.start)])
                display(['    stop    : ' datestr(obj.stop) ' (' num2str(obj.stop-obj.start) ' days)'])
                display(['    max_vei : ' num2str(obj.max_vei)])
                display(' ')
                display(['    Info from Steph - '])
                display(['      forecastyn   : ' num2str(obj.forecastyn) ' (' obj.forecastyn_str ')'])
                display(' ')
            
            else
                
                display(' ')
                display('----------------------------------------------------')
                display(' Empty ERUPTION object')
                display(' ')
                display(['    start   : '])
                display(['    stop    : '])
                display(['    max_vei : '])
                display(' ')
                display(['    Info from Steph - '])
                display(['      forecastyn   : '])
                display(' ')
                
            end
            
        end % if
        
    end
    
end
    
    
%% Dependent GET functions

methods
    
    % These are codes assigned by SP in her spreadsheet
    function val = get.forecastyn_str(obj) 
    
        switch obj.forecastyn
            
            case -1
                
                val = 'No network';
                
            case 0
                
                val = 'Not forecast';
                
            case 1
                
                val = 'Forecast';
                
            case 2
                
                val = 'Forecast unclear';
                
            otherwise
                
        end
            
    
    end
    
    % duration of the eruption in days
    function val = get.duration(obj)
       
        val = obj.stop - obj.start;
        
    end
    
end

%% GET/SET FUNCTIONS

methods
    
    % GET
    function val = get(obj, prop)
        
        
        for j = 1:length(obj)
            
            switch prop
                
                case 'volcano_name'
                    
                    val{j} = obj(j).volcano_name;
                    
                case 'max_vei'
                    
                    val(j) = obj(j).max_vei;
                    
                case 'forecastyn'    
                    
                    val(j) = obj(j).forecastyn;
                    
                case 'start'    
                    
                    val(j) = obj(j).start;
                    
                case 'stop'
                    
                    val(j) = obj(j).stop;
                    
                otherwise
                    
            end
            
        end
        
    end
    
end % methods

%% OTHER METHODS

methods

    % puts the objects in chronological order
    function obj = chron(obj)
        
        [~, idx] = sort(get(obj, 'start'));
        obj = obj(idx);
        
    end % sort

end % methods

end
