function GAP = computeMaxStationGap(eqlat,eqlon,staLat,staLon)

%{
compute the maximum station azimuthal gap
J. PESICEK 11/2017
%}

error('Does not work yet')

nsta = length(staLat);

AZ = azimuth(eqlat,eqlon,staLat,staLon);

AZ(AZ>180) = AZ(AZ>180)-360;
AZ = sort(round(AZ));

GAP = min(abs(AZ)) + max(abs(AZ));


figure
plot(staLon,staLat,'bo',eqlon,eqlat,'go')
title(num2str(GAP))
end