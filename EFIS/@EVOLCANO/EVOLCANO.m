classdef EVOLCANO
    %EVOLCANO Stories information for a particular volcano
    % This is named EVOLCANO because our scripts already use VOLCANO with
    % Helena's stuff. Consider changing the var name for Helena's stuff.
    %
    % Properties
    %
    % name          : 'str'         : Primary volcano name
    % vid           : 'str'         : Volcano ID Number
    %                                    (Internal database ID)
    % vnum          : 'str'         : Volcano Number ID
    %                                   Public/External ID - used to connect
    %                                   with other databases and for
    %                                   webdisplay
    % lat           : double        :
    % lon           : double        :
    % elev          : double        :
    % composition   : {cell array}  : e.g., andesite | basalt
    % status
    % tag           : {cell array}  : e.g., open | closed | caldera
    
    %%
    
    properties
        
        name;           % primary name
        vid;
        vnum;
        lat;
        lon;
        elev;
        country;
        GVP_morph_type;
        tectonic_setting;
        composition;    % andesite | basalt
        tag;            % open | closed | caldera
        
        chronology;
        network;
        
        misc_fields;    % spot for additional fields such as forecast/not_forecast, beta_results,
        %         beta_result;
        
    end
    
    
    methods
        
        % Class constructor
        function obj = EVOLCANO(name, lat, lon, elev, varargin)
            
            if nargin>0
                
                obj.name = name;
                obj.lat = lat;
                obj.lon = lon;
                obj.elev = elev;
                obj.network = ChannelTag;
                obj.chronology;
                
            else
                
                
            end
            
        end
        
        % disp over-ride
        function disp(obj)
            
            if numel(obj)==1
                
                disp(' ')
                disp('  ~~')
                disp(' /\')
                disp('------------')
                fprintf('%s\n', upper(obj.name))
                fprintf(' %s (%6.4fo, %7.4fo, %im)\n', obj.country, obj.lat, obj.lon, obj.elev)
                fprintf(' Morphological Type: %s\n', obj.GVP_morph_type)
                fprintf(' Composition: %s\n', obj.composition)
                if isempty(obj.chronology)
                    disp(' ')
                    disp('NO ERUPTION CHRONOLOGY')
                    disp(' ')
                else
                    obj.chronology
                end
                NETWORK = obj.network
                disp('------------')
                disp(' ')
                
            else
                
                disp(obj2table(obj))
                
            end
            
        end
        
        % GET method - 1 prop at a time
        function val = get(obj, prop)
            
            switch prop
                
                case {'name', 'vnum', 'vid'}
                    
                    for n = 1:numel(obj)
                        val{n} = obj(n).(prop);
                    end
                    
                case {'lat', 'lon', 'elev'}
                    
                    val = size(obj);
                    for n = 1:numel(obj)
                        val(n, :) = obj(n).(prop);
                    end
                    
                case 'coords'
                    
                    val = size(obj, 3);
                    for n = 1:numel(obj)
                        val(n, 1) = obj(n).lat;
                        val(n, 2) = obj(n).lon;
                        val(n, 3) = obj(n).elev;
                    end
                    
                otherwise
                    
                                
            end
            
        end
        
        
    end
    
    
end
