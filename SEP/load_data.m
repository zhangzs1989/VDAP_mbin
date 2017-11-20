function f = load_data(loaded_history)
% LOAD_DATA(loaded_history). Keyword: SEPlib
%
% Reads all the data, but not the history file (SREAD does both).
% Will read integer(esize=1), real (esize=4) and complex (esize=8) data
%
% input: a structure, as outputted by LOAD_HISTORY or GIVEMEASEPSTRUCT
%
% output: the same structure, but also containing the data
% For more information on what it reads, look into the FROM_HISTORY and 
% LOAD_HISTORY help sections
%
% See also FROM_HISTORY, GIVEMEASEPSTRUCT, LOAD_HISTORY, LOADSEGYHEADERS, 
% LOADSEGYTRACES, READ_VECTOR, SEP_DIMENSIONS, SEP_READ, SREAD, SWRITE

% Last revised: Nick Vlad, Aug. 2003

f = loaded_history;

checkreal(f.n,'The n field of the input structure should be a real vector')
checkreal(f.o,'The o field of the input structure should be a real vector')
checkreal(f.d,'The d field of the input structure should be a real vector')

checkvector(f.n,'The n field of the input structure should be vector (1xN or Nx1)')
checkvector(f.o,'The o field of the input structure should be vector (1xN or Nx1)')
checkvector(f.d,'The d field of the input structure should be vector (1xN or Nx1)')

if length(f.n)~=length(f.o) | length(f.o)~=length(f.d)
   error('Lengths of vectors in the n,o,d fields of structure must be the same')
end

if strcmp(f.data_format,'xdr_float')==0 & strcmp(f.data_format,'native_byte')==0 & strcmp(f.data_format,'native_float')==0
   error(cat(2,'data_format must be xdr_float, native_float or native_byte, not ',f.data_format)); 
end

if ~ischar(f.in)
   error('The in field of the input structure should be a string')
end

if f.esize~=1 & f.esize~=4 & f.esize~=8
   error('Data must be 1-byte (esize=1), real (esize=4) or complex (esize=8)')
end
% Igor's trick to read little endians 
% assume big endian
format = 'ieee-be';
% check computer
[~,~,endian]=computer;
% if endian is 'L', and data format is native*, set format to little endian
if( strcmp(endian,'L') == 1 && strncmp(f.data_format,'native',5) == 1 )
  format = 'ieee-le';
end

fid=fopen(f.in,'r',format);
if fid==-1 error(cat(2,'Cannot open ',f.in)); end
if size(f.n)==[1 1]
   f.data = zeros(1,f.n);
else
   f.data = zeros(f.n);
end

f.data(1:prod(f.n))=sep_read(prod(f.n),fid,f.esize);

fclose(fid);
