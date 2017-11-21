function [lonlatdep,sname] = getSwarmStationCoords(FileName)
 
% read config file from swarm 

[channelTag,Longitude,Latitude,Elevation] = importSwarmStationConfig(FileName);

for i=1:length(channelTag)
    stat = char(channelTag(i).station);
%     stat = stat(1:4);
    sname{i} = deblank(stat);

end

[Y,I] = sort(sname);
sname = Y';

lonlatdep = [Longitude(I), Latitude(I), -Elevation(I)];

