classdef JMAVIS
    %JMAVIS Information pertaining to Visual Observations at JMA volcanoes
    %
    % Properties
    %
    % VN    : 'str'     : Volcano name
    % VID   : 'str'     : GVP Volcano Number
    % LOC   : table     : Locations and codes for observation location
    % Data  : table     : Observation data
    % .
    % .
    %      .
    %      .
    %      .
    % .
    %
    % 

    
    properties
        
        VN = '';
        VID = [];
        TN;
        OB;
        LOC;
        RM;
        Data;
        
    end
    
    
    properties(Constant)
        
        filenameformat = 'Vyyyymm.csv';
        filenameyearidx =  2:5
        metadataRowNames = {'VN', 'TN', 'OB', 'LC', 'RM'};
        
        
        headerRow = 'Year,Month,Day,Hour,Minute,Col,Q,H (m),Dir,Loc,Remark,,,,,,'
        headerYearIdx = 1;

    end
    
    methods
        
        % DISP overload function
        function disp(obj)
            
            
            if numel(obj)==1
                disp([obj.VN ' (' num2str(height(obj.Data)) ' observations)']);
                disp(['   .VID  : ' obj.VID])
                disp('   .Data : ')
                disp(obj.Data);
            else
                disp(['1 x ' num2str(numel(obj)) ' JMAVIS objects'])
            end
            
        end
        
        % GET method
        function val = get(obj, property)
            
            for n = 1:numel(obj)
                
                switch property
                    
                    case 'VN'
                        
                        val{n} = obj(n).VN;
                        
                    case 'Data'
                        
                        val(n) = obj(n).Data;
                        
                    case 'VID'
                        
                        val{n} = obj(n).VID;
                        
                end
                
            end
            
        end
        
        % SET method
        function obj = set(obj, property, val)
            
            for n = 1:numel(obj)
                
                switch property
                    
                    case 'VN'
                        
                        obj(n).VN = val{n};                        
                        
                    case 'Data'
                        
                        obj(n).Data = val(n);
                        
                    case 'VID'
                        
                        obj(n).VID = val{n};
                        
                end
                
            end
            
        end
        
        % Remove lines from a table that are Null Reports
        obj = rmnullreports(obj);
        
    end
    
    % Static methods defined in separate files
    methods(Static)
        
        D = rdvisobs(filename);
        D = readSingleVisObsFile(filename);
        C = importVisObs2RawCellArray(filename);
        C = vis_columns();
        
    end
    
end

