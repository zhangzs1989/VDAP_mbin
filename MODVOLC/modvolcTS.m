function ax = modvolcTS( data )
%MODVOLCTS Plots basic timeseries for all data

figure;
ax(1) = subplot(511); plot(data.DateTime, data.B21);
ax(2) = subplot(512); plot(data.DateTime, data.B22);
ax(3) = subplot(513); plot(data.DateTime, data.B6);
ax(4) = subplot(514); plot(data.DateTime, data.B31);
ax(5) = subplot(515); plot(data.DateTime, data.B32);

linkaxes(ax, 'x');

figure;
plot(data.DateTime, data.B21, '*r');

end

