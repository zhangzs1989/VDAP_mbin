function [ bin_mag ] = cumMagByBetaBin( bin_sizes, bins, eq_times, eq_magnitudes )
% CUMMAGBYBETABINS Calculates the cumulative magnitude from earthquakes
% released during a given beta window
%
% INPUT
% BINS - [n-by-m double] An n-by-m matrix of dates that represent the start
% time of beta bins where each column is a vector of dates for a given bin
% size
% EQ_TIMES - vector of datenums representing the date and time of eq
% occurences
% EQ_MAGNITUDES - vector of magnitudes corresponding to EQ_TIMES
%
% OUTPUT
% BIN_MAG - a matrix of cumulative earthquake magnitude accumulated over
% each beta bin corresponding to BIN. Same size as BIN.
%
% USAGE
%
%
%

%%

eq_times = datenum(eq_times); % ensures that eq_times is a datenum
eq_moment = magnitude2moment(eq_magnitudes);
bin_mom = zeros(size(bins));
bin_mag = nan(size(bins));

% for c = 1:size(bins, 2) % for each column; i.e., for each bin size
for c = 1:numel(bin_sizes) % for each column; i.e., for each bin size

    for r = 1:size(bins,1)-1 % for each row; i.e., for each bin start date (for a given bin size)
        
        if ~isnan(bins(r, c))
            
%             date_range = [bins(r, c) bins(r+1, c)];
%             cum_moment = sum(eq_moment(eq_times >= date_range(1) & eq_times < date_range(2)));
            date_range = [bins(r, c)-bin_sizes(c) bins(r, c)]; % first check time minus bin length to the the first check time
            bin_mom(r, c) = sum(eq_moment(eq_times > date_range(1) & eq_times <= date_range(2)));
            bin_mag(r, c) = magnitude2moment(bin_mom(r, c), 'reverse');
            
            % diagnostic print line
%             fprintf(' %s to %s (%3i days), Cum Mag = %2.2f\n', datestr(bins(r,c)-bin_sizes(c)), datestr(bins(r,c)), bins(r,c)-bins(r,c)-bin_sizes(c), bin_mag(r,c))

            
        else
            break
        end
        
                
    end
    
end






end

