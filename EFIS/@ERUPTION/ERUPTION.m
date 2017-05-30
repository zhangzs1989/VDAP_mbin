classdef ERUPTION
    %ERUPTION Stores information related to a specific eruptive episode
    %
    % Properties
    %
    % er_id          : 'str'         : Eruption ID number
    % vid            : 'str'         : Volcano ID that this eruption came from
    % start          : datetime      : Eruption Start Date (Reported)
    % stop           : datetime      : Eruption Stop Date (Reported)
    % max_vei        : double        : Max VEI during this eruption
    %                                   Defined manually or dynamically
    % first_phreatic : datetime      : Date of first phreatic eruption
    %                                   Defined manually or dynamically
    % first_magmatic : datetime      : Date of first phreatic eruption
    %                                   Defined manually or dynamically    
    % explosions     : explosion     : Array of explosion objects tied to a
    %                                   a particular eruption
    %
    % METHODS
    % >> E = ERUPTION(start, stop, max_vei)
    %                   
    
    %%
    
    properties
        
        er_id;
        vid;
        start;              % no specific definition
        stop;               % no specific definition
        max_vei;
        first_phreatic;
        first_magmatic;     
        explosions;         
        
        % temp fields used to hold info from Stephanie
        % eventually, this info should be stores in misc_fields
%         forecastyn;
%         seismonitored;
        
        % future development should take advantage of this feature:
%         misc_fields;        % user defined fields; e.g., forecastyn, seismonitored, etc.
        
    end
    
    
%%

properties (Dependent)
    
%     volcano_name;
    start_stop = [obj.start obj.stop];
    
%     forecastyn_str;
%     duration;
    
end

%% CONSTRUCTOR METHOD

methods
    
    % ERUPTION class constructor
    function obj = ERUPTION( start, stop, max_vei )
        
        % temporary user message
        warning('This is still a preliminary class constructor. It is not very flexible. Please open up the source code to see how it is supposed to be used.')
        
        % error catching
        if start > stop
            error('Start time must be before stop time.')
        end
        
        % construct class
        obj.start = datetime(datevec(start));
        obj.stop = datetime(datevec(stop));
        obj.max_vei = max_vei;
        
    end
    
end
 
%% DISPLAY FUNCTIONS

methods
    
end
    
    
%% Dependent GET functions

% methods
%
%     % These are codes assigned by SP in her spreadsheet
%     function val = get.forecastyn_str(obj) 
%     
%         switch obj.forecastyn
%             
%             case -1
%                 
%                 val = 'No network';
%                 
%             case 0
%                 
%                 val = 'Not forecast';
%                 
%             case 1
%                 
%                 val = 'Forecast';
%                 
%             case 2
%                 
%                 val = 'Forecast unclear';
%                 
%             otherwise
%                 
%         end
%             
%     
%     end
%     
%     % duration of the eruption in days
%     function val = get.duration(obj)
%        
%         val = obj.stop - obj.start;
%         
%     end
%     
% end

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
