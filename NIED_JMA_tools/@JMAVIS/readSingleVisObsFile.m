function D = readSingleVisObsFile( filename )
%READSINGLEVISOBSFILE Reads a single file. Returns results to RDVISOBS
% Does not account for mis-spelled volcano names. That must be done later.
%
% SEE ALSO RDVISOBS

D = JMAVIS; % initialize the JMAVIS object

[~, fname] = fileparts(filename);
year = fname(2:5); % Assumes filename is Vyyyymm.csv

% Open file and create a cell array where each line from the file is a row
C = JMAVIS.importVisObs2RawCellArray(filename);

% Find the start/stop index of each new volcano section
sectionIDX(:,1) = find(ismember(C(:,1), 'VN'));
sectionIDX(:,2) = [sectionIDX(2:end, :)-1; size(C,1)];

% loop through each section,
% parse the metadata (header), and
% parse the data
for i = 1:numel(sectionIDX(:,1))
   
    % grab the rows for this section
   start = sectionIDX(i,1); stop = sectionIDX(i,2);
   section = C(start:stop,:);
   
   % define indices for metadata (header) and data;
   % separate metadata rows and data rows
   headerIDX =  find(ismember(section(:, 1), {'VN', 'TN', 'OB', 'LC', 'RM'}));
   dataIDX = find(ismember(section(:, 1), {'Year', year}));
   header = section(headerIDX', :);
   data = section(dataIDX', :);
   
   % parse metadata and data
   D(i).VN = parseVisObsHeader(header);
   D(i).Data = parseVisObsData(data);
 
   % change the name if the name is mis-spelled or inconsistently spelled
%    D(i) = fixKnownMisSpellings(D(i));
           
end

end

%%

% store things like the volcano name and the location codes
function name = parseVisObsHeader(cellarray)

% loop through each row
for i = 1:numel(cellarray(:, 1))
    
    switch upper(cellarray{i,1})
        
        case upper('VN')
            
            name = upper(strip(cellarray{i, 2}, ' '));
            
        otherwise
            
    end
    
end

end

% create table from cell array of data
function T = parseVisObsData(cellarray)
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

end

% remove extraneous characters (RMEXTRACH)
function C = rmextrch( C )

C = strrep(C, '~', '');
C = strrep(C, '-', '');
C = strrep(C, '_', '');
C = strrep(C, 'X', '');
C = strrep(C, 'x', '');
C = strrep(C, ' ', '');
C = strrep(C, '\t', '');

end
