%%% read JMA Unified Hypocenters HTML
% Reads daily HTML files that contain text info of located events

start = datetime(2002,June,

wr = webread('http://www.data.jma.go.jp/svd/eqev/data/daily_map/20170331.html');

a = strfind(wr, '<pre>');
b = strfind(wr, '</pre>');
data = wr(a+5:b-1);
data = strsplit(data, '\n');

for l = 4:numel(data)-1
    
    info = data{l}; info(~ismember(info,['A':'Z' 'a':'z' '0':'9' ])) = ' ';
    D{l} = info;
    
end