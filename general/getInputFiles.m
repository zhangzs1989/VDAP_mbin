function [inputs,params] = getInputFiles(InputFileName)

%{
this function reads a text file where parameters are defined using matlab
syntax and loads the parameters into the workspace. Used to load params and
inputs structure variables for use in other functions

J.PESICEK, 2017
%}
%%
inputs = [];
params = [];

if exist(InputFileName,'file')
    
    fid1=fopen(InputFileName,'r');
    if fid1 ~= -1
        while 1
            
            par = fgetl(fid1);
            if ~ischar(par)
                break;
            end
            
            eq = strfind(par,'=');
            T=evalc([par(1:eq)  par(eq+1:end) ]);
            
        end
    end
    
else
    disp(InputFileName)
    error('input file does not exist')
end

end