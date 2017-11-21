function catalog = event2catalog(eventFile,outFile)

% this function converts a event.dat file from HypoDD (ph2dt) to our
% internal ANSS .mat format
% J. PESICEK FEB 2016

data = load(eventFile);
catalog = {};
FID = fopen(outFile,'w');
if FID == -1
    error(['Unable to open variable file ' outFile])
end
fhead = 'time latitude longitude depth mag';
fprintf(FID,'%s\n',fhead);

for n = 1:size(data,1)
    
    yyyymmdd = int2str(data(n,1));
    hhmmssss = num2str(data(n,2),'%08d');
    hhmm = hhmmssss(1:4);
    ssss = hhmmssss(5:8);
    s = [ssss(1:2),'.',ssss(3:4),'0'];
    fecha = [yyyymmdd,hhmm,s];
    
    catalog(n).DateTime = datestr(datenum(fecha,'yyyymmddHHMMSS.FFF'));
    catalog(n).Latitude = (data(n,3));
    catalog(n).Longitude = (data(n,4));
    catalog(n).Depth = (data(n,5));
    catalog(n).Magnitude = (data(n,6));
    catalog(n).MagType = 'ML'; %data(n,6);
    catalog(n).NbStations = NaN; %cell2mat(data(n,7));
    catalog(n).Gap = NaN; %data(n,8);
    catalog(n).Distance = NaN; %cell2mat(data(n,9));
    catalog(n).RMS = data(n,9);
    catalog(n).Source = 'AV'; %data(n,11);
    catalog(n).EventID = data(n,10);
    
        % replace empty Magnitudes with NaN values
    if isempty(catalog(n).Magnitude); catalog(n).Magnitude = NaN; end;
    fprintf(FID,'%s',datestr(datenum(fecha,'yyyymmddHHMMSS.FFF'),'yyyy-mm-ddTHH:MM:SS.FFFZ'));
    fprintf(FID,' %7.3f %7.3f %3.1f %2.1f\n',catalog(n).Latitude,catalog(n).Longitude,catalog(n).Depth,catalog(n).Magnitude);
    
end
% now need to output it like NEIC download format
fclose(FID);

end