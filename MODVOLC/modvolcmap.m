function modvolcmap( data )
%MODVOLCMAP Basic map of Modvolc data
% INPUT
% data - table of Modvolc data created by IMPORTMODVOLCDATA
%

%%

plot(data.Longitude, data.Latitude, 'or');


end

