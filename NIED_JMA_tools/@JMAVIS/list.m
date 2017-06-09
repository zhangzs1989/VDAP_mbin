function list( obj )
%LIST List an array of JMAVIS objects by volcano name and number of
%observations

for n = 1:numel(obj)
    disp([num2str(n, '%02d') '. ' obj(n).VN ' (' num2str(height(obj(n).Data)) ' observations)']);
end

end

