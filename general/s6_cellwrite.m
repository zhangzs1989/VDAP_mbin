function s6_cellwrite(filename,cellarray,delimiter,nullelement)
%
% SYNOPSIS ==================
%
% Write an arbirary cell array to disk as a CSV file.
%
%   s6_cellwrite(filename,cellarray,delimiter,nullelement)
%
% If an element of the cell array is not a string or a scalar numeric
% value, the nullelement will be pasted into the CSV file.
%
%
% INPUT =====================
% filename      String. Name of CSV file to use. Required.
% cellarray     Cell array. Any type of cell array. Required.
% delimiter     String. Delimiter to be used by CSV file. Default: ','
% nullelement   String. Element to be pasted if a cell is not printable to
%               disk. Default: '0'
%
%
% Authors:  Mathieu Duclos <mathieu.duclos@spectraseis.com>
%           Nima Riahi <nima.riahi@spectraseis.com>
% (c) Spectraseis AG, first release: 2008-05-14
%
%
% $Id: s6_cellwrite.m,v 1.1 2008/09/08 12:46:16 gigi Exp $

if nargin<4
    nullelement = '0';
end
if nargin<3
    delimiter = ',';
end

[rows, cols] = size(cellarray);

fid = fopen(filename, 'w');

for i_row = 1:rows

    file_line = '';

    for i_col = 1:cols

        contents = cellarray{i_row, i_col};
        [ncellr, ncellc] = size(contents);

        if ischar(contents) && ncellr==1
            % Good cell element. Do nothing
        elseif ncellr==1 && ncellc==1 && isnumeric(contents)
            % Only consider scalar numeric values
            contents = num2str(contents);
        else
            % In all other cases output the null element
            contents = nullelement;
        end

        if i_col < cols
            file_line = [file_line, contents, delimiter];
        else
            file_line = [file_line, contents];
        end
    end

    fprintf(fid, '%s\n', file_line);

end

fclose(fid);

end