function [lonlatdep,sname] = getSwarmStationCoords(FileName)
 
% read config file from swarm or other ad hoc format
try
    [channelTag,Longitude,Latitude,Elevation] = importSwarmStationConfig(FileName);
    if sum(~isnan(Longitude))==0
        [channelTag,Latitude,Longitude,Elevation] = importStationFile(FileName);
    end
catch
    [channelTag,Latitude,Longitude,Elevation] = importStationFile(FileName);
end

for i=1:length(channelTag)
    try
        stat = char(channelTag(i).station);
    catch
        stat = char(channelTag(i));
    end
    sname{i} = deblank(stat);

end

[Y,I] = sort(sname);
sname = Y';

lonlatdep = [Longitude(I), Latitude(I), -Elevation(I)];

