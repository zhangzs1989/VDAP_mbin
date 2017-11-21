function swrite(d,new_history_file)
% SWRITE(data_structure,new_history_file_name). Keyword: SEPlib
%
% Writes the structure onto a history text file and a binary file
%
% Input: a structure and a string. For structure syntax see GIVEMEASEPSTRUCT.
% The string should contain the file extension; and path if not in cur. dir 
%
% Output: nothing in Matlab workspace, just writes files:
% a history file in the current directory, and a binary in scratch
%
% This function will write:
% integer (esize=1, data_format='native_byte', data = double or uint8)
% real    (esize=4, data_format='xdr_float'  , data = double, real   )
% complex (esize=8, data_format='xdr_float'  , data = double - real or complex)
%
% See also SREAD, GIVEMEASEPSTRUCT. Related, but used more rarely:
% FROM_HISTORY, LOAD_DATA, LOAD_HISTORY, LOADSEGYHEADERS, LOADSEGYTRACES,
% READ_VECTOR, SEP_DIMENSIONS, SEP_READ

% Last revised: Nick Vlad, Aug. 2003

iswindows=checkwindows;
if iswindows error('The current version does not run under DOS/Windows'); end

if ~ischar(new_history_file)
   error('Second input argument must be character string')
end

checkreal(d.n,'The ''n'' field of the structure should be a real vector')
checkreal(d.o,'The ''o'' field of the structure should be a real vector')
checkreal(d.d,'The ''d'' field of the structure should be a real vector')

checkvector(d.n,'The ''n'' field of the structure must be a vector (nx1 or 1xn)')
checkvector(d.o,'The ''o'' field of the structure must be a vector (nx1 or 1xn)')
checkvector(d.d,'The ''d'' field of the structure must be a vector (nx1 or 1xn)')

if length(d.n)~=length(d.o) | length(d.o)~=length(d.d)
   error('Lengths of the ''n'', ''o.., and ''d'' fields of structure must be the same!')
end

if d.esize~=1 & d.esize~=4 & d.esize~=8
   error('The ''esize'' field of the structure must be either 1, 4, or 8')
end

if strcmp(d.data_format,'xdr_float')==0 & strcmp(d.data_format,'native_byte')==0 & strcmp(d.data_format,'native_float')==0 
   error(cat(2,'data_format must be xdr_float or native_byte, not ',d.data_format)); 
end

if ischar(d.data) | islogical(d.data)
   error('The ''data'' structure field must be numeric array (uint8, real or complex)')
end
is_float = (strcmp(d.data_format,'native_float') == 1 || strcmp(d.data_format,'xdr_float') == 1);
if d.esize==1 & strcmp(d.data_format,'native_byte')==1 & isreal(d.data)
   % do nothing, everything OK
% elseif d.esize==4 & strcmp(d.data_format,'xdr_float')==1 & isreal(d.data)
elseif d.esize==4 & is_float & isreal(d.data)
   d.data=double(d.data); % in case data is uint8, change it to double:
% elseif d.esize==8 & strcmp(d.data_format,'xdr_float')==1 
elseif d.esize==8 & is_float 
   d.data = complex(double(real(d.data)),double(imag(d.data))); % in case it was uint8
else
   error('Match esize, data_format and the kind of data according to swrite''s help')
end

if length(d.n)~=length(size(d.data))
   error('Length of n, o and d vectors must equal the number of data dimensions')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(d.history_file)
   if exist(d.history_file,'file')
      [s,w] = unix(cat(2,'cp ',d.history_file,' ',new_history_file));
      if s~=0
	 [t,w] = unix(cat(2,'echo ''Cannot copy ',d.history_file,' to ',new_history_file,''' > ',new_history_file));
	 if t~=0
	    error(cat(2,'Cannot write to ',new_history_file))
	 end
      end
   else
      [s,w] = unix(cat(2,'echo ''',d.history_file,', the old history file specified in the Matlab structure, does not exist'' > ',new_history_file));       
   end
end

fid_new_hist=fopen(new_history_file,'at');
if fid_new_hist==-1 error(cat(2,'Cannot open ',new_history_file,' for writing')); end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[status1,user]=unix('whoami');
user(length(user))=[];

[status2,hostname]=unix('hostname');
hostname(length(hostname))=[];

[status,whentime] = unix('date');

fprintf(fid_new_hist,cat(2,'\nMatlab: ',user,'@',hostname,' on ',whentime));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
new_scratch_file=strcat(pwd,'/',new_history_file,'@');
fprintf(fid_new_hist,cat(2,'\nsets next: in="',new_scratch_file,'"'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(d.n)
	fprintf(fid_new_hist,strcat('\n n',num2str(i),'=',num2str(d.n(i))));
end
for i=1:length(d.o)
	fprintf(fid_new_hist,strcat('\n o',num2str(i),'=',num2str(d.o(i))));
end
for i=1:length(d.d)
	fprintf(fid_new_hist,strcat('\n d',num2str(i),'=',num2str(d.d(i))));
end

fprintf(fid_new_hist,strcat('\n esize','=',num2str(d.esize)));
fprintf(fid_new_hist,strcat('\n data_format','="',num2str(d.data_format),'"'));
fprintf(fid_new_hist,'\n End of Matlab-written history \n \n \n');
fclose(fid_new_hist);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Igor's trick to read little endians 
% assume big endian
format = 'ieee-be';
% check computer
[~,~,endian]=computer;
% if endian is 'L', and data format is native*, set format to little endian
if( strcmp(endian,'L') == 1 && strncmp(d.data_format,'native',5) == 1 )
  format = 'ieee-le';
end




fid_new_data=fopen(new_scratch_file,'w',format);
if fid_new_data==-1 
   error(cat(2,'Cannot open ',new_scratch_file,' for writing'))
end

if d.esize == 1
   count=fwrite(fid_new_data,d.data,'uint8');
elseif d.esize == 4
   count=fwrite(fid_new_data,d.data,'float32');
elseif d.esize == 8
   tempreal=0;tempimag=0;countreal=0;countimag=0;
   for k=1:prod(size(d.data))
       tempreal=real(d.data(k));
       tempimag=imag(d.data(k));
       countreal=fwrite(fid_new_data,tempreal,'float32');
       countimag=fwrite(fid_new_data,tempimag,'float32');
   end
end

fclose(fid_new_data);
