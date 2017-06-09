function [ V, C ] = rdveq( filename )
%RDVEQ Reads file of volcanic earthquake counts as reported by JMA
%   Monthly files can be downloaded at the following website:
%   http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/veq.html
%
%   Each file contains one month of data for all volcanoes. The file is
%   broken into sections - one section per volcano. Columns contain daily
%   counts of various earthquake types, but the number of columns vary from
%   volcano to volcano.
%

v = 0; % number of volcano/observatory pairs processed 

for f = 1:numel(filename)
    
    % Open file and create a cell array where each line from the file is a row
    % in cellarray C
    fid = fopen(filename{f});
    C = textscan(fid, '%s', 'delimiter', '\n');
    C = C{1,1};
    fclose(fid);
    
    % Find the index of each new volcano
%     newvolc = strfind(C, 'Numbers');
    newvolc = strfind(C, 'VN');
    newvolc = find(not(cellfun('isempty', newvolc)));
    
    for i = 1:numel(newvolc)
        
        v = v+1;
        V(v) = JMAVEQ; % create a JMAVEQ object
        [startidx, stopidx] = getSectionIdx(C, newvolc, i);
        
        target_year = [];
        nob = 0; % number of observatories recorded
        nrm = 0; % number of 'Remarks' lines
        
        % These are the lines pertaining to this volcano
        for j = startidx:stopidx
            
            tline = strip(C{j,:}, ',');
            tline = strsplit(tline, ',');
            tline = strip(tline, ' ');
            
            switch tline{1}
                
                case 'VN'
                    
                    V(v).VN = tline{2};
                    
                case 'TN'
                    
                    
                    TN = [tline{2} '/' tline{3}];
                    target_year = tline{2};
                    V(v).TNds = datestr(TN, 'yyyy/mm');
                    V(v).TNdn = datenum(V(v).TNds);
             
                case 'OB'
                    
                    if numel(tline)>1
                        nob = nob+1;
                        V(v).OB = tline{2};
                    else
                        V(v).OB = V(v).VN;
                    end
                    
                case 'RM'
                    
                    if numel(tline)>1
                        nrm = nrm+1;
                        V(v).RM = tline{2}; 
                    else
                        V(v).RM = 'No remarks.';
                    end
                    
                % identifies the header
                case 'Year'
                    

                    if ~strcmpi(V(v).VN,'Kirishimayama')
                        
                        % eq types
                        % Lines that start with 'Year' look like this:
                        % 'Year,Month,Dat,Type1,Type2,...,TypeN,Total,Remarks'
                        % * 'Remarks' may or may not be present
                        % Therefore, earthquake counts for each type are in columns
                        % 4:C-1, where C is the total number of columns in the line
                        eq_header = tline;
                        year_idx = find(cellfun('length',regexp(tline,'Year')) == 1);
                        month_idx = find(cellfun('length',regexp(tline,'Month')) == 1);
                        day_idx = find(cellfun('length',regexp(tline,'Day')) == 1);
                        total_idx = find(cellfun('length',regexp(tline,'Total')) == 1);
                        remarks_idx = find(cellfun('length',regexp(tline,'Remarks')) == 1);
                        types_lgc = ismember(tline, JMAVEQ.veq_types);
                        types_idx = find(types_lgc, numel(types_lgc));
                                                
                        data = [];
                        for l = j+1:stopidx
                            
                            dline = C{l, :};
                            dline = strrep(dline, 'X', '0'); % no data
                            dline = str2double(strip(strsplit(strip(dline, ','), ','), ' '));
                            try
                                if lineHasData(dline, eq_header, V(v))                     
                                    data = [data; dline];
                                end
                            catch
                                disp(' ')
                            end

                        end
                        
                        try
                        eq_counts = data(:, types_idx);
                        eq_types = upper(eq_header(types_lgc));
                        ndays = max(data(:, day_idx));
                        EQC = JMAVEQ.emptyveqtable(ndays);
                        EQC = assignCounts2Variables(EQC, eq_types, eq_counts);
                        EQC.DateNum = datenum(data(:,1), data(:,2), data(:,3));
                        EQC.DateTime = datetime(datestr(EQC.DateNum));
                        catch
                            disp(' ')
                        end

%                         if %%%
                            V(v).C = EQC;
%                         else
%                             V(v).C = JMAVEQ.emptyveqtable(0);
%                         end/

                    end
                
                otherwise
                    
            end % switch
            
        end
        
    end % volcano iteration
    
end % file iteration

    
end

%% internal functions

    
    function T = assignCounts2Variables(T, varnames, datamatrix)
        
        for n = 1:numel(varnames)
            
            T{:, matlab.lang.makeValidName(varnames{n})} = datamatrix(:,n);
            
        end
                            
    end

    % get the start and stop indices for the section for this volcano
    function [val1, val2] = getSectionIdx(filelines, section, i)
        
        val1 = section(i);
        
        if i == numel(section)
            
            val2 = numel(filelines);
            
        else
            
            val2 = section(i+1)-1;
            
        end
        
    end
    
    % series of diagnostic tests aimed at verifying that a line that is
    % supposed to have earthquake counts actually does have earthquake
    % counts
    % thisline should be the str2double of the ',' and ' ' stripped
    % text line
    function b = lineHasData(thisline, header, veq_obj)
    
        dv = datevec(veq_obj.TNdn);
        
        % thisline should not be empty
        if isempty(thisline)
            b = 0; disp('Line is empty.'); return;
        
        % the string should have the year in position 1
        elseif thisline(1) ~= dv(1)
            b = 0; return;
            
        else
            b = 1;
        end
    
    end
