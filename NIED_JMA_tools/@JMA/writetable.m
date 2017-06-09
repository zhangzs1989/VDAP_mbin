function writetable( obj, field, directory, varargin )
% JMA.WRITETABLE( obj, field, directory ) Writes table information
% from a JMA data object to a text file
%
% Works just like WRITETABLE but appends a column in the output
% that contains the VID number. File names are generated
% automatically based on obj.VN. Thus, the user specified the
% directory, not the filename.
% Accepts all variable input arguments accepted by WRITETABLE
%
% USAGE
% >> VIS = JMAVIS(...);
% >> JMA.writetable( VIS, 'Data', '/Users/jmadataanalyst/visual_data.txt')
%
% SEE ALSO WRITETABLE

% Make the directory if it does not exist
if ~exist(directory, 'dir')
    mkdir(directory)
end

% for each object,
% produce a column in the table with VID numbers, and
% write the table
for i = 1:numel(obj)
    obj(i).(field).VID = repmat({obj(i).VID}, [height(obj(i).(field)) 1]);
    writetable(obj(i).(field), fullfile(directory, [obj(i).VN '.csv']), ...
        varargin{:});
end

end