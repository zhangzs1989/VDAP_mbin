T = readtable('/Users/jaywellik/Downloads/epicentros-1917-2016-cvss-para-vdap.xlsx')
date = datetime(T.fecha)

HHmm = replace(T.hora(:), ' ', '0')
HHmm = strsplit(sprintf('%04s ',HHmm{:}), ' ')
HHmm = HHmm(1:end-1)
HHmm = datetime(HHmm, 'InputFormat', 'HHmm')'
dt = date + timeofday(HHmm) + seconds(T.segundos)
dt.Format = 'yyyy/MM/dd HH:mm:ss.S'
catalog.DATETIME = dt
T(1,:)
catalog.LAT = T.latitud
catalog.LON = T.longitud
catalog.MAG = T.mag_max
catalog.DEPTH = T.prof_
catalog = struct2table(catalog)


% subplot(1,6,1:4), plot(catalog.DATETIME, catalog.MAG, 'ok')
% subplot(1,6,6), timemap(catalog.DATETIME, catalog.LAT, catalog.LON, 'ok')
% f = gcf
% linkaxes(f.Children, 'x')