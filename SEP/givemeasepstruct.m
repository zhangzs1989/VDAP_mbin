function S = givemeasepstruct(o, d, data)
% S = GIVEMEASEPSTRUCT(o, d, data) Keyword: SEPlib
% Output: a structure ready to be written with swrite into SEPlib format
%
% Input arguments:
%
% o:	1-D real array with the origins of the axes [o1 o2 o3...]
% d:	1-D real array with the increments along the axes [d1 d2 d3...]
% data:	real or complex array with the same number of dimensions as the 
%	number of elements in o_vector and d_vector
% Example: S = givemeasepstruct([0 0 0], [1 1 1], zeros(5,5,5))
% For vector: T = givemeasepstruct([0 0], [1 1], zeros(5,1))
%
% See also SREAD, SWRITE. Related, but used more rarely:
% FROM_HISTORY, LOAD_DATA, LOAD_HISTORY, LOADSEGYHEADERS, LOADSEGYTRACES,
% READ_VECTOR, SEP_DIMENSIONS, SEP_READ

% Last revised: Nick Vlad, Aug. 2003


checkreal(o,'First input argument should be a real vector')
checkreal(d,'Second input argument should be a real vector')

checkvector(o,'First input argument should be a vector (nx1 or 1xn)')
checkvector(d,'Second input argument should be a vector (nx1 or 1xn)')

if length(o)~=length(d)
   error('Lengths of vectors for 1st and 2nd arguments must be the same')
end

if ischar(data) | islogical(data)
   error('Last argument must be numeric array (integer, real or complex)')
elseif isreal(data)
   data=double(data);
   esize = 4;
else % if data is complex
   data = complex(double(real(data)),double(imag(data)));
   esize = 8;
end

n=size(data);
if length(d)~=length(n)
   error('Length of 2nd and 3rd argument vectors must equal the number of data dimensions')
end

S.history_file = []; % does not come from a previous .H file
S.n            = n;
S.o            = o;
S.d            = d;
S.esize        = esize;
S.in           = [];
S.data_format  = 'xdr_float';
S.data         = data;
