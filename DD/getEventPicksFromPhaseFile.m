function [EventPicks, OT, coords] = getEventPicksFromPhaseFile(ID,phaseFile,stations)

%{ 
this function takes in an event ID and a phase file and returns only those
picks for the event
%}

if ischar(ID)
    ID = str2double(ID);
end

% nsta = numel(stations);
%load in travel times
% tts(1,nsta*2+1) = nan;

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
            lat = str2num(line(26:33));
            lon = str2num(line(35:43));
            dep = str2num(line(45:51));
%             mag = str2num(line(53:57));
%             eh = str2num(line(59:64));
%             ez = str2num(line(66:70));
%             rms = str2num(line(72:76));
            id = strtrim(line(78:87));
            %             tts(e,1) = str2double(id);
            coords = [lon,lat,dep];
            
            if str2double(id) ~= ID
                %                 disp(id)
                line = fgetl(fid1);
                while line(1) ~= '#' & line ~= -1
                    line = fgetl(fid1);
                end
                continue
            end
            
            % EQ OT
            fecha = sprintf('%04d%02d%02d%02d%02d%5.2f',yr,mo,dy,hr,mn,sc);
            fecha = datenum(fecha,'yyyymmddHHMMSS.FFF');
            OT = fecha;
%             id2=datestr(fecha,'yyyymmddHHMMSS.FFF');
            
            line = fgetl(fid1);
            
            phaCt = 0;
            % need to instead read in all phase lines into matrix
            while line(1) ~= '#' & line ~= -1
                
                if ~isempty(find(strcmp(stations,strtrim(line(1:7))), 1)) % only stations in station list
                    phaCt = phaCt + 1;
                    EventPicks(phaCt,1) = {strtrim(line(1:7))};
                    pickTime = OT + datenum(0,0,0,0,0,str2double(strtrim(line(8:15))));
%                      EventPicks(phaCt,2) = {strtrim(line(8:15))};
                    EventPicks(phaCt,2) = {datestr(pickTime,'yyyymmddHHMMSS.FFF')};
                    EventPicks(phaCt,3) = {strtrim(line(17:23))};
                    EventPicks(phaCt,4) = {strtrim(line(27))};
                end
                
                line = fgetl(fid1);
                
            end
            
            break
            
            %             if ~ischar(line)
            %                 break;
            %             end
        end
    end
end

fclose(fid1);

end