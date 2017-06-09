classdef JMA
    %JMA Parent class for all JMA data
    %
    
    properties
        
        VN;
        TN;
        TNdn;
        TNds;
        OB;
        RM;
        VIS;
        CAT;
        VEQ;
        
        
    end
    
    % Static methods defined in separate files
    methods(Static)
        
        download(data_type, start, stop, directory, varargin);
        obj = readfile(filename);
        obj = readSingleFile(filename);
        C = importFile2CellArray(filename, n);
        str = filetype(filename);
        writetable(obj, field, directory, varargin);
        
    end
    
end

