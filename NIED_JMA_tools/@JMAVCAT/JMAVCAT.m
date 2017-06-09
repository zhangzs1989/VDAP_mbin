classdef JMAVCAT
    %JMAVCAT 
    %
    % Properties
    %
    % VN        : 'str'     : Volcano name
    % VID       : 'str'     : GVP Volcano Number
    % RawCat    : table     : Observation data
    %                           as it appears in the input files
    % .DATETIME     : datetime  : event time
    % .NO           : cell      : event number
    % .TYPE         : cell      : event classification
    % .OPOINT       : cell      : observation point (station)
    % .DUR          : cell      : signal duration (sec)
    % .REMARK       : []        : comments; currently unimplemented
    % CAT       : table     : Catalog of earthquake times and other info
    % .DATETIME
    % .TYPE
    % .DUR_AVG
    % .NSTA
    % .OPOINTS
    
    
    properties
        
        VN = '';
        VID = [];
        
        RawCat;
        CAT;
        
    end
    
    properties(Constant)
        
        filenameformat = 'Eoyyyymm.csv';
        filenameyearidx =  3:6;
        metadataRowNames = {'VN', 'TN'};
        
        headerRow = 'No.,Year,Month,Day,Hour,Minute,Type,Opoint,Okind,P,P_time,S,S_time,X,X_time,SP,Dur,Pn,Pe,Pz,Mn,Tn,Me,Te,Mz,Tz,Unit,Remarks';
        headerYearIdx = 2;
        
    end
    
    methods
        
        % GET method
        function val = get(obj, property)
            
            for n = 1:numel(obj)
                
                switch property
                    
                    case 'VN'
                        
                        val{n} = obj(n).VN;
                        
                    case 'RawCat'
                        
                        val(n) = obj(n).RawCat;
                        
                    case 'VID'
                        
                        val{n} = obj(n).VID;
                        
                    case 'Events'
                        
                        val(n) = obj(n).Events;
                        
                end
                
            end
            
        end
        
        % SET method
        function obj = set(obj, property, val)
            
            for n = 1:numel(obj)
                
                switch property
                    
                    case 'VN'
                        
                        obj(n).VN = val{n};
                        
                    case 'RawCat'
                        
                        obj(n).RawCat = val(n);
                        
                    case 'Events'
                        
                        obj(n).Events = val(n);
                        
                    case 'VID'
                        
                        obj(n).VID = val{n};
                        
                end
                
            end
            
        end
        
    end
    
    methods(Static)
        
        obj = rdvcat(filename);
        obj = rdSinglevcat(filename);
        C = importVCat2RawCellArray(filename);
        C = vcat_columns();
        
    end
    
end

