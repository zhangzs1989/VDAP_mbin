function D = readSingleFile( filename )
%READSINGLEFILE 
%   Determines the type of file

%% Set variables based on file type

ftype = JMA.filetype(filename);
% NOTE: Why use strrep?
%{
Some filenames are 'Eo_yyyymm.csv'; other filenames are 'Eoyyyymm.csv'.
Replacing '_'s with ''s eliminates inconsistency and allows the year to
always be read as characters 3:6.
%}

[~, fname, ~] = fileparts(filename);
fname = strrep(fname, '_', '');

switch upper(ftype)
    
    % JMAVIS - Visual Observations
    case 'V'
        
        D = JMAVIS;

        
    % JMAVCAT - Volcano Earthquake Catalog    
    case 'EO'
        
        D = JMAVCAT; % initialize the JMAVCAT object

    % JMATREM - Tremor Catalog    
    case 'TR'
        
        
        
    otherwise
        
        error('Filetype is not recognized.')

end

%%

% Open file and create a cell array where each line from the file is a row
try
C = JMA.importFile2CellArray(filename);
catch
    disp(['Error reading file: ' filename])
    return
end
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
    metadataIDX =  find(ismember(section(:, 1), D(1).metadataRowNames));
    dataIDX = find(ismember(section(:, D(1).headerYearIdx), {'Year', fname(D(1).filenameyearidx)} ));
    metadata = section(metadataIDX', :);
    data = section(dataIDX', :);
    
    % parse metadata and data
    % NOTE: Each data type has its own parseMetadata and parseData routine.
    % The proper routine is specified by the object type of the first input
    D(i) = D(1);
    D(i) = parseMetadata(D(i), metadata);
    D(i) = parseData(D(i), data);
    
end

end