function ecatalog = reloc2anss(relocFile)

% this function converts a hypoDD.loc file from HypoDD to our
% internal ANSS .mat format
% J. PESICEK FEB 2016

data = load(relocFile);
ecatalog = {};

for n = 1:size(data,1)
    
    yyyy = data(n,11);
    m = data(n,12);
    d = data(n,13);
    H = data(n,14);
    M = data(n,15);
    S = data(n,16);
    
          
    ecatalog(n).DateTime = datestr(datenum(yyyy,m,d,H,M,S/100));
    ecatalog(n).Latitude = (data(n,2));
    ecatalog(n).Longitude = (data(n,3));
    ecatalog(n).Depth = (data(n,4)); 
    ecatalog(n).Magnitude = (data(n,17));
    ecatalog(n).MagType = 'ML'; %data(n,6);
    ecatalog(n).NbStations = NaN; %cell2mat(data(n,7));
    ecatalog(n).Gap = NaN; %data(n,8);
    ecatalog(n).Distance = NaN; %cell2mat(data(n,9));
    ecatalog(n).RMS = NaN;
    ecatalog(n).Source = 'AV'; %data(n,11);
    ecatalog(n).EventID = data(n,1);
  
        % replace empty Magnitudes with NaN values
    if isempty(ecatalog(n).Magnitude); ecatalog(n).Magnitude = NaN; end;
    
end

end