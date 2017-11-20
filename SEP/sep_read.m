function f=sep_read(nelem, fid, esize)
% SEP_READ(nelem, fid, esize). Keyword: SEPlib
%
% nelem: scalar. How many elements to read
% fid  : file identificator. File must be already open. See usage in LOAD_DATA
% esize: 1 for integer data (.T), 4 for real, 8 for complex
% 
% Useful for reading the data one piece at a time, to save memory
%
% See also FROM_HISTORY, GIVEMEASEPSTRUCT, LOAD_DATA, LOAD_HISTORY, 
% LOADSEGYHEADERS, LOADSEGYTRACES, READ_VECTOR, SEP_DIMENSIONS, SREAD, SWRITE

% Last revised: Nick Vlad, Aug. 2003

if esize == 1
   f(1:nelem) = fread(fid,nelem,'uint8');
   
elseif esize == 4
   f(1:nelem) = fread(fid,nelem,'float32');

elseif esize == 8
   for k=1:nelem
       f(k)=fread(fid,1,'float32')+i*fread(fid,1,'float32');
   end

else
   error('esize must be 1, 4 or 8')
end
