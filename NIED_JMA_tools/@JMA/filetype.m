function type = filetype( filename )
%FILETYPE Returns the filetype of the given file
%   Detailed explanation goes here

%%

[~, fname, ~] = fileparts(filename);
ftype = fname(isletter(fname));

type = ftype;


end

