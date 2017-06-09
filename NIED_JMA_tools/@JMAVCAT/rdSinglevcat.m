function D = rdSinglevcat( filename )
%RDSINGLEVCAT Reads a single file. Returns the results to RDVCAT
%
% SEE ALSO RDVCAT

% Example from beginning of a file:
%{
Volcanic Earthquake/Tremor Observation,,,,,,,,,,,,,,,,,,,,,,,,,,,
VN,Atosanupuri,,,,,,,,,,,,,,,,,,,,,,,,,,
TN,2013,3,,,,,,,,,,,,,,,,,,,,,,,,,
No.,Year,Month,Day,Hour,Minute,Type,Opoint,Okind,P,P_time,S,S_time,X,X_time,SP,Dur,Pn,Pe,Pz,Mn,Tn,Me,Te,Mz,Tz,Unit,Remarks
1,2013,3,14,5,27,A ,ADMK,V, P,39.15, , ,,, , , , , ,1.22,0.12,1.41,0.1,0.91,0.1,mkine,
1,2013,3,14,5,27,A ,AAT2,V, P,39.17, S,40.29,,,1.12, , , , ,1.38,0.06,1.93,0.04,0.76,0.04,mkine,
2,2013,3,18,10,30,A ,AAT2,V, P,31.96, S,33.1,,,1.14, , , , ,0.25,0.06,0.18,0.06,0.13,0.04,mkine,
%}

D = JMAVCAT; % initialize the JMAVCAT object

[~, fname] = fileparts(filename);
year = strrep(fname(3:6), '_', ''); % Assumes filename is Eoyyyymm.csv
% NOTE: Why use strrep?
%{
Some filenames are 'Eo_yyyymm.csv'; other filenames are 'Eoyyyymm.csv'.
Replacing '_'s with ''s eliminates inconsistency and allows the year to
always be read as characters 3:6.
%}

% Open file and create a cell array where each line from the file is a row
C = JMA.importFile2CellArray(filename);

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
   headerIDX =  find(ismember(section(:, 1), {'VN', 'TN'}));
   dataIDX = find(ismember(section(:, 2), {'Year', year}));
   header = section(headerIDX', :);
   data = section(dataIDX', :);
    
   % parse metadata and data
   D(i).VN = parseVCatHeader(header);
   D(i).Data = parseVCatData(data); 
           
end



end

