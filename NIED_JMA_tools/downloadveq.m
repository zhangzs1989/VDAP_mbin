function downloadveq( start, stop )
%DOWNLOADVEQ Downloads and saves volcano earthquake count data from the JMA website
% Data are downloaded in the pwd
% Downloads data from:
%   'http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/data/veq/'
%
% Each downloaded file contains a single month's worth of event count data
% by type for multiple volcanoes.
% The result of DOWNLOADVEQ will produce 1 JMAVEQ object for each volcano
% for each month. Use COMBINEVOLCANO to build a continuous timeseries for a
% single volcano
%
% USAGE
%   >> downloadveq( start, stop )
%
% SEE ALSO combinevolcano
%

%%


base_url = 'http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/data/veq/';
disp('Downloading data from:')
disp(['  ' base_url ])
    
start = datetime(datestr(start));
stop =  datetime(datestr(stop));
t = start;

while t <= stop
    
    ds = datestr(t, 'yyyymm');
    filename = ['En' ds '.zip'];
    try
        websave(filename, fullfile(base_url, filename));
        disp(['Downloading data for ' ds '...'])
        unzip(filename); delete(filename);
    catch
        disp(['No data available for ' ds '.'])
        delete([filename '.html']);
    end
    t = t+calmonths(1);

end

disp('Data download complete.')
end

