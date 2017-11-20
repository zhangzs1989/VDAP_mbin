function f_result=sread(history_file)
% SREAD(history_file). Keyword: SEPlib
%
% Reads into a structure: filename, binary path, n, o, d, esize, data_format, 
% and data. Argument: SEPlib history file to read from. Matlab string.
% Examples:	   S = sread('~/rhubarb.H');
%		   hist = '../rhubarb.H'; S = sread(hist);
%		   S = sread('rhubarb.H')
%
% Equivalent to: LOAD_DATA(LOAD_HISTORY(history_file))
%
% See also SWRITE, GIVEMEASEPSTRUCT. Related, but used more rarely:
% FROM_HISTORY, LOAD_DATA, LOAD_HISTORY, LOADSEGYHEADERS, LOADSEGYTRACES,
% READ_VECTOR, SEP_DIMENSIONS, SEP_READ

% Last revised: Nick Vlad, Aug. 2003

f_result=load_data(load_history(history_file));
