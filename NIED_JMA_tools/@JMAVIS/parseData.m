function obj = parseData(obj, cellarray)
% PARSEDATA for a JMAVIS object
%{
The input to this function is a cell array of the header row for the data
followed by each line of data. As a csv string, it should look like this:
Year,Month,Day,Hour,Minute,Col,Q,H (m),Dir,Loc,Remark,,,,,,
2008,1,1 ,9 ,0 ,W,1,50,S,M,…I…Ï…l…g≈[…J…≈…‚«?« «»,,,,,,
2008,1,1 ,9 ,0 ,W,1,50,S,N,…I…Ï…l…g≈[…J…≈…‚«?« «»,,,,,,
2008,1,1 ,9 ,0 ,X,X,X,X,TU,ÓwÂi«√‚_«?Ëd«ª«ÀÓ™Ô†ÔsÓ\,,,,,,
2008,1,1 ,15 ,0 ,W,1,30,S,M,…I…Ï…l…g≈[…J…≈…‚«?« «»,,,,,,
%}

%indices for the header line and the data lines
headerlineIDX = find(ismember(cellarray(:, 1), 'Year'));
dataIDX = ~ismember(cellarray(:, 1), 'Year'); % this is actually a logical vector
headerline = cellarray(headerlineIDX', :);
nrows = sum(dataIDX); % number of rows of data

% create an empty table with all of the valid column names
T = cell2table(cell(nrows, numel(JMAVIS.vis_columns)), ...
    'VariableNames', JMAVIS.vis_columns);

for c = 1:size(cellarray,2)
    
    
    switch upper(strip(cellarray{headerlineIDX, c}, ' ')) % make sure there are no extra spaces
        
        case 'YEAR'
            idx = ismember(headerline, {'Year' 'Month' 'Day' 'Hour' 'Minute'});
            DateCell = cellarray(dataIDX, idx);
            Year = str2double(cellstr(DateCell(:, 1)));
            Month = str2double(cellstr(DateCell(:, 2)));
            Day = str2double(cellstr(DateCell(:, 3)));
            Hour = str2double(cellstr(DateCell(:, 4)));
            Minute = str2double(cellstr(DateCell(:, 5)));
            Second = zeros(size(Minute));
            T.DATETIME = datetime(Year, Month, Day, Hour, Minute, Second);
            
        case 'EVENT'
            
            idx = ismember(headerline, 'Event');
            T.EVENT = rmextrch(cellarray(dataIDX, idx));
            
        case 'COL'
            
            idx = ismember(headerline, 'Col');
            T.COL = rmextrch(cellarray(dataIDX, idx));
            
        case 'Q'
            
            idx = ismember(headerline, 'Q');
            T.Q = str2double(rmextrch(cellarray(dataIDX, idx)));
            
        case 'H (M)'
            
            idx = ismember(headerline, 'H (m)');
            T.H = rmextrch(cellarray(dataIDX, idx));
            
        case 'DIR'
            
            idx = ismember(headerline, 'Dir');
            T.DIR = cellarray(dataIDX, idx);
            
        case 'LOC'
            
            idx = ismember(headerline, 'Loc');
            T.LOC = cellarray(dataIDX, idx);
            
        case 'REMARK'
            
            idx = ismember(headerline, 'Remark');
            T.REMARK = cellarray(dataIDX, idx);
            
        otherwise
            
    end
    
end

obj.Data = T;

end