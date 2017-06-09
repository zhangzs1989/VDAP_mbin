function D = rdvisobs( filename )
%RDVISOBS Reads files of visual observations from the JMA
% SEE ALSO READSINGLEVISOBSFILE

D = [];
for f = 1:numel(filename)
   
   d = JMAVIS.readSingleVisObsFile(filename{f});
   D = [D d];
    
end

end

