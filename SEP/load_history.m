function f = load_history(history_file)
% LOAD_HISTORY(history_file). Keyword: SEPlib
%
% Input argument must be character string. Reads n, o, d, esize and data_format
% from history_file into a structure
%
% Examples:
% hist='rhubarb.H'; S=load_history(hist) or
% S=load_history('../Hfiles/rhubarb.H')
%
% See also FROM_HISTORY, GIVEMEASEPSTRUCT, LOAD_DATA, LOADSEGYHEADERS, 
% LOADSEGYTRACES, READ_VECTOR, SEP_DIMENSIONS, SEP_READ, SREAD, SWRITE
%
% For detailed description of output, type "type load_history" in Matlab

%===========================Output argument:===========================
% The output structure has the fields: 
%     history_file: name and path of the file being read. Char string.
%     n           : numbers of elements along each dimension in the data cube
%     o		  : origins of axes
%     d		  : increments along axes
%		  (n,o,d are real vectors for which the numeric value of each 
%		  element is specified individually, with no blank spaces
%		  immediately to the left or right of the '=' sign. I.E.,
%		  n1=4 n2=5 are valid assignments, while n1 =4, n2= 4 and 
%		  n3 = 4 are not. n(1) is not a vector element, n1 is. Valid 
%		  Matlab scientific notation is ok: o1=5e+04 is ok, o2=1.23E-23
%		  is also ok, d3=e-2 is not ok, it should be d3=1e-2 or 1.0e-2
%     esize	  : size of sample on disk, in bytes.
%     in	  : path to binary correspondent of history_file. Char string
%     data_format : Char string that describes encoding of samples. Most common
%		  is 'xdr_float' for esize=4 or 8 and 'native_byte' for esize=1
%
% The comment sign inside the history file is #, anything that follows
%	after it on a line is discarded.
%
% Last revised: Nick Vlad, Aug. 2003

if ~ischar(history_file) error('input must be character string'); end

f.history_file = history_file;
f.n            = read_vector (history_file, 'n'          );
f.o            = read_vector (history_file, 'o'          );
f.d            = read_vector (history_file, 'd'          );
f.esize        = from_history(history_file, 'esize',8    );
f.in           = from_history(history_file, 'in'         );
f.data_format  = from_history(history_file, 'data_format');
