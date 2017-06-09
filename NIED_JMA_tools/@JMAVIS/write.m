function write( obj, directory )
%WRITE Uses write table to write out data as csv file
%   Writes 1 file per object
%   Appends a column that contains the VID for each row
%
% USAGE
% >> write( obj, directory )

%%

% Make the directory if it does not exist
if ~exist(directory, 'dir')
    mkdir(directory)
end

% for each object,
% produce a column in the table with VID numbers, and
% write the table
for i = 1:numel(obj)
    obj(i).Data.VID = repmat({obj(i).VID}, [height(obj(i).Data) 1]);
    writetable(obj(i).Data, fullfile(directory, [obj(i).VN '.csv']));
end
    
end

