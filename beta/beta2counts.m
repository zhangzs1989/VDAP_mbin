function Na = beta2counts(B, N, Ta, T)
% BETA2COUNTS Converts a beta value to the corresponding counts
%
% INPUT
% B     : beta value
% N     : events in entire time period
% Ta    : length of time of interest
% T     : length of entire time period
%
% OUTPUT
% Na    : events in window of interest (counts)

% betas=(Na-N*(Ta/T))/sqrt(N*(Ta/T)*(1-(Ta/T))); % equation for beta
Na = B * sqrt(N*(Ta/T)*(1-(Ta/T))) + N*(Ta/T); % equation for counts
