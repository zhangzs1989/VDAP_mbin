function f_result=normalize(x)
% normalize(x), brings the values of x between 0 and 1. 

sx=size(x);
nelem=prod(sx);
y=reshape(x,nelem,1);
marele=max(y);
micul=min(y);
x=x-micul;
x=x/(marele-micul);
f_result=x;