function t=obj2table(obj)
%%OBJ2TABLE Converts an object array to a table
w=warning('off','MATLAB:structOnObject');
t=struct2table(arrayfun(@struct, obj));
warning(w);
end