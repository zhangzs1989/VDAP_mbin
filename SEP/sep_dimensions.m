function ndim = sep_dimensions(history_file)
% SEP_DIMENSIONS(history_file). Keyword: SEPlib
%
% Returns the numer of dimensions of the SEP data (real scalar)
% as last specified in history_file (character string). If the last value(s)
% are equal to 1 they will not be read.
%
% See also FROM_HISTORY, GIVEMEASEPSTRUCT, LOAD_DATA, LOAD_HISTORY, 
% LOADSEGYHEADERS, LOADSEGYTRACES, READ_VECTOR, SEP_READ, SREAD, SWRITE

% Last revised: Nick Vlad, Aug. 2003

% This code will look in history_file for the biggest ni, i increasing 
%	gradually, until there are no more ni. Trims any last ni that are
%	equal to 1, until the biggest ni that is not equal to 1.

i=1;

while 1
	curname = strcat('n',num2str(i));
	curval  = from_history(history_file, curname);
	if ischar(curval)
	   if i==1 
	      error('No dimensions vector found')
	   else
	      break
	   end
	end
	f(i)=curval;
	i=i+1;
end

% Tail trimming

while 1
      ndim=length(f);
      if ndim==1 break; end
      if f(ndim)==1
	 f(ndim)=[];
      else
	 break
      end
end
