function [OTimes] = getOTimesFromPhaseFile(phaseFile)

fid1=fopen(phaseFile,'r');
e=0;
if fid1 ~= -1
    line = fgetl(fid1);
    while 1
        
        if ~ischar(line)
            break;
        end
        
        if line(1) == '#'
            %             disp('  !!  EVENT LINE  !!')
            e = e + 1;
            yr = str2num(line(3:6));
            mo = str2num(line(8:9));
            dy = str2num(line(11:12));
            hr = str2num(line(14:15));
            mn = str2num(line(17:18));
            sc = str2num(line(20:24));
            
            %             lat = str2num(line(26:33));
            %             lon = str2num(line(35:43));
            %             dep = str2num(line(45:51));
            %             mag = str2num(line(53:57));
            %             eh = str2num(line(59:64));
            %             ez = str2num(line(66:70));
            %             rms = str2num(line(72:76));
            id = strtrim(line(78:87));
            
            % EQ OT
            fecha2 = sprintf('%04d%02d%02d%02d%02d%5.2f',yr,mo,dy,hr,mn,sc);
            fecha(e) = datenum(fecha2,'yyyymmddHHMMSS.FFF');
%             id2=datestr(fecha(e),'yyyymmddHHMMSS.FFF');
%             otdiff(e) = abs(etime(datevec(OTtime),datevec(fecha(e))));
     
        end
        line = fgetl(fid1);
       
    end
end

% disp(' ')
% I = find(otdiff==min(otdiff));
% closestMatchTime = fecha(I);
% elapsedSeconds = otdiff(I);
OTimes = fecha';

end