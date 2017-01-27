classdef alertLevel
    %ALERTLEVEL Class for handling alert levels
    %
    %   PROPERTIES
    %       date    : datenum of alert level changes
    %       level   : numeric level (1 through n)
    %       schema  : alertLevelSchema obj
    %
    %       plot_start  : beginning of plot (default -> January 1, 1950)
    %       plot_end    : end of plot (default -> now)
    %
    %   *Ensures that all dates are in the proper order
    %
    %   USAGE
    %   >> A = alertLevel(date, level)
    %   >> A.schema = alertLevelSchema.predefined('AVO')
    %

    
    properties
        
        date; % datenum of alert level changes
        level; % numeric level
        schema; % alert level schema
        
        plot_start = datenum('1950/1/1');
        plot_end = now;
        
    end
    
    methods
        
        % class constructor
        function obj = alertLevel(date, level)
            
            % ensure that date and level must have the same number of
            % values
            if numel(date)~=numel(level), error('DATE and LEVEL must have the same number of values.'); end
            
            % make sure everything is in chronological order
            [date, I] = sort(date);
            level(I) = level;
            
            % assign values (ensure that values are n-by-1 row vectors)
            obj.date(:,1) = date;
            obj.level(:,1) = level;
            
        end
        
        % Display information about color code and changes to the command window
        function disp(obj)
            
            DATE = datetime(datestr(obj.date));
            LEVEL = obj.level;
            T = table(DATE, LEVEL);
            disp(T)
            disp(' ')
            disp(['     plot_start : ' datestr(obj.plot_start)])
            disp(['     plot_end   : ' datestr(obj.plot_end)])
            
        end
        
        
        
    end
    
end

