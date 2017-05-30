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
    % Dependent Properties (use GET)
    % start_stop    : n-by-2 datetime   : start/stop pairs for eruptions
    %
    % METHODS
    % >> E = ERUPTION(start, stop, max_vei)
    %                   
    
    %%
    
    properties
        
        volcano;
        vid;
        vnum;
        explosion_id;
        echron_activity_id;
        activity_id;
        episode_id;
        subevent_yn;
        number_exp;
        number_exp_mod;
        event_name;
        colh_above_summit;
        max_colh_asl;
        max_col_h_error;
        vol_dre;
        vol_dre_error;
        vei;
        vei_source;
        vei_method;
        type_code;
        style;
        keywords;
        comments;
        start;        
        qual;
        start_date_error;
        start_time_mod;
        start_time_error;
        stop;
        end_day_mod;
        end_date_error;
        end_time_mod;
        end_time_error;
        
        parents;
        children;
        
        er_id;
%         vid;
%         start;              % no specific definition
%         stop;               % no specific definition
        max_vei;
        first_phreatic;
        first_magmatic;     
%         type_code;
%         style;
%         keywords;
%         comments;
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
    
    % Class Constructor
    function obj = ERUPTION(start, stop, max_vei)
        
        if nargin ~= 0
            
            for n = 1:numel(start)
                obj(n) = ERUPTION;
                obj(n).start = start(n);
                obj(n).stop = stop(n);
                obj(n).max_vei = max_vei(n);
            end
            
        end
        
    end
    
end
 
%% DISPLAY FUNCTIONS

methods
    
end
    
    
%% Dependent GET functions



%% GET/SET FUNCTIONS

methods
    
    
end % methods

%% OTHER METHODS

methods

    % puts the objects in chronological order
    function obj = chron(obj)
        
        [~, idx] = sort(get(obj, 'start'));
        obj = obj(idx);
        
    end % sort

end % methods

methods(Static)
    
    % Controls the datacursor display on an eruption plot
    output_text = eruption_datacursor(~, event_obj, obj, ax_start)
    
end % static Methods

end
