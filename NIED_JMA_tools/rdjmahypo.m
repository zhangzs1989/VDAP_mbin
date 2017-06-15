%%% rdjmahypo

file = '/Users/jjw2/Dropbox/JAY-DATA/JMADATA/hypocenters/h2015';

T = readtable(file, 'Delimiter', '\n', 'Format', '%s', 'ReadVariableNames', 0);

line = T{1, :}; line = line{:};
yyyy = str2double(line(2:5));
MM = str2double(line(6:7));
dd = str2double(line(8:9));
HH = str2double(line(10:11));
mm = str2double(line(12:13));
ss = str2double(line(14:17))/100;
D.DateTime = datetime(yyyy,MM,dd,HH,mm,ss);
latd = str2double(line(22:24));
latm = str2double(line(25:28))/100;
D.Latitude = dm2degrees([latd latm])
lond = str2double(line(33:36));
lonm = str2double(line(37:40))/100;
D.Longitude = dm2degrees([lond lonm])
D.Depth = str2double(line(45:49))/100
D.Magnitude = str2double(line(53:54))/10 % needs to be special parsing for negatives