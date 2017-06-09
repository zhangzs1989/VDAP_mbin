function obj = parseData( obj, data )
%PARSEDATA Parse data for JMAVCAT
% INPUT
%   obj         :
%   data        : cell array of earthquake catalog data
%

% data cell array, e.g.:
%{
  20×35 cell array
  Columns 1 through 20
    'No.'    'Year'    'Month'    'Day'    'Hour'    'Minute'    'Type'    'Opoint'    'Okind'    'P'    'P_time'    'S'    'S_time'    'X'    'X_time'    'SP'      'Dur'    'Pn'    'Pe'    'Pz'
    '1'      '2013'    '3'        '14'     '5'       '27'        'A '      'ADMK'      'V'        'P'    '39.15'     ''     ''          ''     ''          ''        ''       ''      ''      ''  
    '1'      '2013'    '3'        '14'     '5'       '27'        'A '      'AAT2'      'V'        'P'    '39.17'     'S'    '40.29'     ''     ''          '1.12'    ''       ''      ''      ''  
    '2'      '2013'    '3'        '18'     '10'      '30'        'A '      'AAT2'      'V'        'P'    '31.96'     'S'    '33.1'      ''     ''          '1.14'    ''       ''      ''      ''  
    '2'      '2013'    '3'        '18'     '10'      '30'        'A '      'ADMK'      'V'        ''     ''          ''     ''          ''     ''          ''        ''       ''      ''      ''  
    '3'      '2013'    '3'        '20'     '23'      '42'        'A '      'AAT2'      'V'        'P'    '2.39'      'S'    '3.51'      ''     ''          '1.12'    ''       ''      ''      ''  
    '3'      '2013'    '3'        '20'     '23'      '42'        'A '      'ADMK'      'V'        ''     ''          ''     ''          ''     ''          ''        ''       ''      ''      ''  
    '4'      '2013'    '3'        '24'     '13'      '4'         'A '      'ADMK'      'V'        ''     ''          ''     ''          ''     ''          ''        ''       ''      ''      ''  
%}

%indices for the header line and the data lines
headerlineIDX = find(ismember(data(:, 1), 'No.'));
dataIDX = ~ismember(data(:, 1), {'No.', 'Tn'}); % this is actually a logical vector
dataIDX(1:headerlineIDX) = 0;
headerline = data(headerlineIDX', :);
nrows = sum(dataIDX); % number of rows of data

% create an empty table with all of the valid column names
T = cell2table(cell(nrows, numel(JMAVCAT.vcat_columns)), ...
    'VariableNames', JMAVCAT.vcat_columns);

for c = 1:size(data,2)
    
    
    switch upper(strip(data{headerlineIDX, c}, ' ')) % make sure there are no extra spaces
        
        case 'YEAR'
            idx = ismember(headerline, {'Year' 'Month' 'Day' 'Hour' 'Minute'});
            DateCell = data(dataIDX, idx);
            Year = str2double(cellstr(DateCell(:, 1)));
            Month = str2double(cellstr(DateCell(:, 2)));
            Day = str2double(cellstr(DateCell(:, 3)));
            Hour = str2double(cellstr(DateCell(:, 4)));
            Minute = str2double(cellstr(DateCell(:, 5)));
            Second = zeros(size(Minute));
            T.DATETIME = datetime(Year, Month, Day, Hour, Minute, Second);
            
        case 'NO.'
            
            idx = ismember(headerline, 'No.');
            T.NO = data(dataIDX, idx);
            
        case 'TYPE'
            
            idx = ismember(headerline, 'Type');
            T.TYPE = data(dataIDX, idx);
            
        case 'OPOINT'
            
            idx = ismember(headerline, 'Opoint');
            T.OPOINT = data(dataIDX, idx);
            
        case 'DUR'
            
            idx = ismember(headerline, 'Dur');
            T.DUR = data(dataIDX, idx);        
            
        case 'REMARK'
            
            idx = ismember(headerline, 'Remark');
            T.REMARK = data(dataIDX, idx);
            
        otherwise
            
    end
    
end

obj.RawCat = T;


end

