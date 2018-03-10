function ecatalog = event2anss(eventFile)

% this function converts a event.dat file from HypoDD (ph2dt) to our
% internal ANSS .mat format
% J. PESICEK FEB 2016

data = load(eventFile);
ecatalog = {};

for n = 1:size(data,1)
    
    yyyymmdd = int2str(data(n,1));
    hhmmssss = num2str(data(n,2),'%08d');
    hhmm = hhmmssss(1:4);
    ssss = hhmmssss(5:8);
    s = [ssss(1:2),'.',ssss(3:4),'0'];
    fecha = [yyyymmdd,hhmm,s];
    
    ecatalog(n).DateTime = datestr(datenum(fecha,'yyyymmddHHMMSS.FFF'));
    ecatalog(n).Latitude = (data(n,3));
    ecatalog(n).Longitude = (data(n,4));
    ecatalog(n).Depth = (data(n,5));
    ecatalog(n).Magnitude = (data(n,6));
    ecatalog(n).MagType = 'ML'; %data(n,6);
    ecatalog(n).NbStations = NaN; %cell2mat(data(n,7));
    ecatalog(n).Gap = NaN; %data(n,8);
    ecatalog(n).Distance = NaN; %cell2mat(data(n,9));
    ecatalog(n).RMS = data(n,9);
    ecatalog(n).Source = 'AV'; %data(n,11);
    ecatalog(n).EventID = data(n,10);
    
        % replace empty Magnitudes with NaN values
    if isempty(ecatalog(n).Magnitude); ecatalog(n).Magnitude = NaN; end;
    
end

end