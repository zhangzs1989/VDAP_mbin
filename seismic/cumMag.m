function [ cum_mag, cum_moment ] = cumMag( magnitude )
% CUMMAG A simple function that outputs cumulative Magnitude and Moment
% from a time series.
%   Calculates cumulative magnitude and cumulative moment from a time
%   series of earthquake magnitudes. NaN values are ignored.
% see also MAGNITUDE2MOMENT

moment = magnitude2moment(magnitude); % convert each magnitude to a moment
id_nan = isnan(magnitude); % index of all nan magnitude values
moment(id_nan) = 0; % temporarily change nan moments to 0;
cum_moment = cumsum(moment); % calculate cumulative moment
cum_moment(id_nan) = nan; % change all moment vales of 0 back to NaN
cum_mag = magnitude2moment(cum_moment,'reverse'); % convert cumulative moment back to cumulative magnitude

end

