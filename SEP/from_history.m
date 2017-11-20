function f_result=from_history(history_file,wanted_variable,default_value)
% FROM_HISTORY(history_file,wanted_variable,default_value) Keyword: SEPlib
% 
% Returns the value of wanted_variable as last specified in history_file
% Returns default_value if wanted_variable is not present in history_file
% The third argument(default_value) is optional. If no present, the result
% contains a string error message
%
% Example:
% hist='rhubarb.H';
% dim1=from_history(hist,'n1',100)
%
% See also GIVEMEASEPSTRUCT, LOAD_DATA, LOAD_HISTORY, LOADSEGYHEADERS, 
% LOADSEGYTRACES, READ_VECTOR, SEP_DIMENSIONS, SEP_READ, SREAD, SWRITE
%
% For more help, type "type from_history" into the line of command

%===========================Output argument:===========================
% Returns the last value of wanted_variable in history_file
% Retrieves both string and numeric variables. Strings are defined as 
%	whatever is surrounded by ' signs, or as any contiguous sequence
%	of characters beginning with a letter. Reads " signs as ' signs
%	and then evaluates as a Matlab statement any continuous sequence
%	of nonblank characters containing the = sign. Thus x=4 s='hjk'
%	z="ind" zs=area51 are all valid statements, while x =4 x= 4 and
%	x = 4 WILL NOT BE EVALUATED. Valid Matlab scientific notation is
%	ok: q=5e+04 is ok, w=1.23E-23 is also ok, xc=e-2 is not ok, like
%	in Matlab, it should be xc=1e-2 or 1.0e-2
% 	
% The comment sign inside the history file is #, anything that follows
%	after it on a line is discarded.

%========================Debugging=====================================
% If you try to modify this program: beware the behavior of Matlab when 
% it attempts to read the end-of-line character and the end-of-file sign
% This made the program 30%longer and 50%less readable than it should be
% Also, beware assigning to the variables in this program names of 
% variables that might be encountered in a history file, use weird names.
% I felt the need to suggestively name the 'Line' variable, though.
%
% Known bugs: crashes when nothing is on the RHS of an equal sign
% i.e.: n2=
%
% Last revised: Nick Vlad, Sep. 2000


fiduladax=fopen(history_file,'rt');
if fiduladax==-1 error(cat(2,'Cannot open ',history_file,' for reading'));end
lungu=strcat(wanted_variable,'=');

while 1
	Line=fgets(fiduladax);
	if Line == -1
		break
	end
	Line=[Line,' '];
	kulahj=findstr(Line,'#');
	if ~isempty(kulahj) % if there is a comment
		kulahj=kulahj(1);
		Line(kulahj:length(Line))=[];
		Line=[Line,'  '];
	end
	Line=strrep(Line,'"','''');
	while 1
		%blank lines and trailing/preceding blanks elimination
		if size(Line)==[1 2] 
			break
		end
		Line(length(Line))=[];
		Line(length(Line))=[];
		Line=deblank(Line);
		Awertaa=isspace(Line);
		for i=1:length(Awertaa)
			if Awertaa(i)==0
				break
			end
			Line(1)=[];
		end
		if isempty(findstr(Line,lungu)) 
			break  % trash the line if it does not have wanted_variable
		else % line consists of several tokens
			while 1
				if size(Line)==[1 0] %problem-causing empty line
					break
				end
				while 1
					if size(Line)==[1 0] %problem-causing empty line
						break
					end
					[tokenu,remu] = strtok(Line); %make the division
					while 1
						fifi=findstr(tokenu,lungu);
						if isempty(fifi) 
							Line=remu; break   %eliminate first token
						end
						% The following lines overlook a second possible 
						% assignment of w_v inside a token
						fifi=fifi(1)+length(lungu);
						if tokenu=='='
							Line=remu;break
						end
						tokenu=tokenu(fifi:length(tokenu)); %cut;only the value of variable is taken
						if tokenu(1)==''''
							if tokenu(length(tokenu))=='''' | tokenu(length(tokenu)-1:length(tokenu))==''';'
							   tokenu=strcat(lungu,tokenu,';');
							   eval(tokenu,'eroarea=5;'); Line=remu; break
							end
							Line=remu; break
						end
						fifi=findstr(tokenu,';');
						if ~isempty(fifi)
							fifi=fifi(1);fifi=min(fifi,length(tokenu));tokenu(fifi:length(tokenu))=' ';
						end
						if isletter(tokenu(1))==1
							tokenu=strcat(lungu,'''',tokenu,'''',';');
							eval(tokenu,'eroarea=5;'); Line=remu; break
						end
						if isletter(tokenu)==zeros(size(tokenu)) | ~isempty([findstr(tokenu,'E+');findstr(tokenu,'E-');findstr(tokenu,'e-');findstr(tokenu,'e+')])
							tokenu=strcat(lungu,tokenu,';');
							eval(tokenu,'eroarea=5;'); Line=remu; break 
						end
						Line=remu; break 
					end
				end
			end
			Line=[Line,' '];break
		end
	end
end

fclose(fiduladax);

if exist(wanted_variable,'var')
	f_result=eval(wanted_variable);
elseif nargin==3
	f_result=default_value;
else
	f_result=cat(2,wanted_variable,' is not present either in ',history_file,' or as a default!');
end
