function [lonlatdep,sname] = getSwarmStationCoords(FileName)
 
% read config file from swarm 

[channelInfo,Longitude,Latitude,Elevation] = importSwarmStationConfig(FileName);

for i=1:length(channelInfo)
    stat = char(channelInfo(i));
    stat = stat(1:4);
    sname{i} = deblank(stat);

end

[Y,I] = sort(sname);
sname = Y';

lonlatdep = [Longitude(I), Latitude(I), -Elevation(I)];

