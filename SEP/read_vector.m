function f = read_vector(history_file,vector_name)
% READ_VECTOR(history_file,vector_name). Keyword: SEPlib
% 
% Both input arguments are character strings. Output is a real vector.
%
% Example: hist='rhubarb.H'; d=read_vector(hist,'d')
%
% See also FROM_HISTORY, GIVEMEASEPSTRUCT, LOAD_DATA, LOAD_HISTORY, 
% LOADSEGYHEADERS, LOADSEGYTRACES, SEP_DIMENSIONS, SEP_READ, SREAD, SWRITE
%
% For more help on vector syntax, type "type read_vector" in Matlab.

% The numeric values of each of the vector's elements is specified 
% individually, with no blank spaces immediately to the left or right of the 
% '=' sign. I.E., n1=4 n2=5 are valid assignments, while n1 =4, n2= 4 and 
% n3 = 4 are not. n(1) is not a vector element, n1 is. Valid Matlab scientific 
% notation is ok: o1=5e+04 is ok, o2=1.23E-23 is also ok, d3=e-2 is not ok, it 
% should be d3=1e-2 or 1.0e-2. A value can be specified several times in the 
% history file; only the last one counts.
% 
% The comment sign inside the history file is #, anything that follows
%	after it on a line is discarded.
%
% The vector length is assumed to be equal to the number of dimensions in
% the data, as read with sep_dimensions(history_file)! You can rewrite the code
% for vector length autodetect by using code from sep_dimensions
%
% Last revised: Nick Vlad, Aug. 2003
if ~ischar(history_file) error('First input must be character string'); end
if ~ischar(vector_name)  error('Second input must be character string'); end

N = sep_dimensions(history_file);
f=zeros(1,N);
for i=1:N
    element_name=strcat(vector_name,num2str(i));
    curval = from_history(history_file,element_name,0);
    if ischar(curval) error(cat(2,'Assign numerical value in ',history_file))
    end
    f(i) = curval;
end
