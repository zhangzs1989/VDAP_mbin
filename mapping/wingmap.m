classdef wingmap
    %WINGMAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        axm = axes; % axis handle for the map
        axh = axes; % axis handle for the horizontal cross section
        axv = axes; % axis handle for the vertical cross section
        axl = axes; % axis handle for the legend
        
        A1 = []; % lat lon coordinates of A1 (A)
        A2 = []; % lat lon coordinates of A2 (A') 
        B1 = []; % lat lon coordinates of B1 (B)
        B2 = []; % lat lon coordinates of B2 (B')
        
        
    end
    
    properties (Dependent)
        
       xsec_angle = getXSecAngle(); 
        
    end
    
    methods
        
        % projects data to a cross section line
        function projectData()
            
        end
        
    end
    
end

