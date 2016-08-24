classdef EVOLCANO
    %EVOLCANO Stories information for a particular volcano
    % This is named EVOLCANO because our scripts already use VOLCANO with
    % Helena's stuff. Consider changing the var name for Helena's stuff.
    %   Detailed explanation goes here

%%    

    properties

        name;
        lat;
        lon;
        elev;
        composition;    % andesite | basalt   
        tag;            % open | closed | caldera

        eruptions;
        network;

        misc_fields;    % spot for additional fields such as forecast/not_forecast, beta_results, 
%         beta_result;    
    

    end
    
    methods
    end
    
end

