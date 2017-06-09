function D = readfile( filename )
%READFILE Reads a file downloaded from the JMA
%   See readSingleFile for more details

D = [];
for f = 1:numel(filename)
   
   d = JMA.readSingleFile(filename{f});
   D = [D d];
    
end

end

