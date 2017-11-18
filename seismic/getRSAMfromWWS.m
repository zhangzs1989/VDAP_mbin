function rsamData = getRSAMfromWWS(chanTag,ds,t1,t2,rsamP)

% requires wget!
% rsamP in seconds
% J. Pesicek
% example:
% http://130.118.152.130:16022/rsam?code=TMKS_EHZ_VG_00&t1=20171101000000&t2=20171117000000&rsamP=3600&csv=1&rm=1&rmp=600

t1 = datestr(t1,'yyyymmddHHMMSS');
t2 = datestr(t2,'yyyymmddHHMMSS');

str=sprintf('http://%s%s%d/rsam?code=%s_%s_%s_%s&t1=%s&t2=%s&rsamP=%d&csv=1&rm=1&rmp=600',...
    get(ds,'server'),char(58),get(ds,'port'),chanTag.station,chanTag.channel,chanTag.network,chanTag.location,...
    t1,t2,rsamP);

cmd=sprintf('/opt/local/bin/wget %s%s%s -O %s',char(39),str,char(39),'/tmp/rsam.csv');
[status,result] = system(cmd);

if status~=0
    warning('wget error')
    details(result)
end

[rsamData,~]=readtext('/tmp/rsam.csv');

end

