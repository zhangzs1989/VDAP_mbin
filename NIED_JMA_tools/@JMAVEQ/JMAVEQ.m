classdef JMAVEQ
    %JMAVEQ Holds event count info for JMA Volcanic Earthquake Counts
    % Each object contains information for one volcano & observatory pair
    %
    % Data are downloaded from the following website:
    %   http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/veq.html
    %
    % See the following website for information and notes on the format:
    %   http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/data/format/venfmt_j.html
    %
    %   Properties
    %   VN     : 'str'  : Volcano name
    %   TN     : []     : (Target Period) Date & Month of data
    %   TNdn   : datenum(TN)
    %   TNds   : datestr(TN)
    %   OB     : 'str'  : Observatory code
    %   RM     : 'str'  : Notes & metadata
    %   C      : table  : Catalog of daily counts by event type
    %   .DateTime       : datetime stamp for the day
    %   .DateNum        : datenum stamp for the day
    %   .<EventType1>  --
    %       .            | n more columns; 1 for each event type
    %       .            | for a list of all event types in the catalog, type
    %       .            | >> JMAVEQ.veq_types
    %       .            | use the links above to find explanations for the abbreviations
    %   .<EventTypeN>  --
    %
    % SEE ALSO downloadveq combinevolcano
    
%%

    properties
        
        VN;
        TN;
        TNdn;
        TNds;
        OB;
        RM;
        C;
        
    end

%%

methods
    
    function val = get(obj, property)
        
        for n = 1:numel(obj)
            
            switch property
                
                case 'VN'
                    
                    val{n} = obj(n).VN;
                    
                case 'TN'
                    
                
                case 'C'
                    
                    val(n) = obj(n).C;
                    
            end
            
        end
        
    end
    
end

%%

    % Static Methods
    methods(Static)
        
        % return cell array of earthquake type abbreviations
        % cellarray size is 1-by-n
        function C = veq_types
            
            C = upper({'A', 'B', 'BH', 'BL', ...
                'BP', 'BT', 'BS', 'EX', ...
                'DL', 'T', 'TC', 'Tk', ...
                'TP', 'Tex', 'Air', 'Pyr'});           
            
        end
        
        % creates an empty table with variables:
        % DateTime, DateNum, eq_type(1), ..., eq_type(16)
        function T = emptyveqtable(ndays)
            
            T = table(zeros(ndays,1), zeros(ndays,1), ...
                zeros(ndays,1), zeros(ndays,1), zeros(ndays,1), zeros(ndays,1), ...
                zeros(ndays,1), zeros(ndays,1), zeros(ndays,1), zeros(ndays,1), ...
                zeros(ndays,1), zeros(ndays,1), zeros(ndays,1), zeros(ndays,1), ...
                zeros(ndays,1), zeros(ndays,1), zeros(ndays,1), zeros(ndays,1), ...
                'VariableNames', [{'DateTime', 'DateNum'} JMAVEQ.veq_types]);
            
        end
        
        
    end
    
    % Static Methods saved ax external file
    methods(Static)
       
        obj = rdveq(filename);
        
    end
    
end

