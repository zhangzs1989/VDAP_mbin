function w2 = mcvco2nan(w)
% MCVCO2NAN Uses decode_mcvco to replace a calibration pulse +/- 5 seconds
% with NaN values

sst = decode_mcvco(w, 'sst');
sst(:,1) = sst(:,1) - 5/86400;
sst(:,2) = sst(:,2) + 5/86400;
isst = interinterval(sst, get(w,'start'), get(w,'start')+get(w,'duration'));
w2 = combine(extract(w, 'time', isst(:,1), isst(:,2)));

% plot(w, 'r'), hold on
% plot(w2)

end