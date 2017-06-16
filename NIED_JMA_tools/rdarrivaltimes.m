function E = rdarrivaltimes( file )
%RDARRIVALTIMES Reads .txt file of arrival times or hypocenters
%   Arrival times with picks can be downloaded under the Subsection of "Arrival time data" at:
%       https://hinetwww11.bosai.go.jp/auth/JMA/?LANG=en
%       * Users must be registered
%       * Use the "UNIX format [LF]" for the download type
%
%   Hypocenter files can be downloaded from:
%       http://www.data.jma.go.jp/svd/eqev/data/bulletin/hypo.html
%       File format explanation: http://www.data.jma.go.jp/svd/eqev/data/bulletin/data/format/hypfmt_j.html
%
%   Returns a table of events

%%

% based on JMA seismological data format (Updated on 2016/04/01)
% << https://hinetwww11.bosai.go.jp/auth/JMA/?LANG=en >>
formatstr = '%1s%4d%2d%2d%2d%2d%4.2f%4.2f%3d%4.2f%4.2f%4d%4.2f%4.2f%5.2f%3.2f%2.1f$1s%2.1f%1s%1s%1s%1s%1s%1s%1s%1d%3d%24s%3d%1s';

fid = fopen( file );
n= 0;
while true
    
    tline = fgets(fid);
    if tline==-1; break; end
    
    % new events have a line that starts with the letter J
    if strcmp(tline(1), 'J')
        
        %disp(tline);
        
        n = n+1;
        event(n).type = tline(1);
        
        % 2:17 - time
        yyyy = str2double(tline(2:5));
        mm = str2double(tline(6:7));
        dd = str2double(tline(8:9));
        HH = str2double(tline(10:11));
        MM = str2double(tline(12:13));
        SS = str2double(tline(14:17))/100;
        
        % save as a datenum and a datestr
        event(n).dn = datenum(yyyy, mm ,dd, HH, MM, SS);
        event(n).ds = datestr(event(n).dn);
        
        % 18:21 - ?
        
        % 22:28 - latitude
        
        latd = str2double(tline(22:24));
        latm = str2double(tline(25:28))/100;
        % event(n).latd = latd; event(n).latm = latm;
        event(n).lat = dm2degrees([latd latm]);
        
        % 29:32 - longitudte
        
        lond = str2double(tline(33:36));
        lonm = str2double(tline(37:40))/100;
        % event(n).lond = lond; event(n).lonm = lonm;
        event(n).lon = dm2degrees([lond lonm]);
        
        % 41:44 - depth
        
        event(n).depth = str2double(tline(45:49))/100;
        
        %45:52 - magnitude
        % see web documentation for meaning of A & B
        
        mag = tline(53:54);
        if strcmp(mag(1), 'A')
            event(n).mag = - str2double(mag(2))/10;
        elseif strcmp(mag(1), 'B')
            event(n).mag = -1 - str2double(mag(2))/10;
        else
            event(n).mag = str2double(mag)/10;
        end
        
    end
    
    
    
end

E = struct2table(event);

end
