function download( data_type, start, stop, directory )
%DOWNLOAD Downloads and saves monthly data files from the JMA website
% Each downloaded file contains a single month's worth of data for multiple
% volcanoes. Use COMBINEVOLCANO to build a continuous timeseries for a
% single volcano
%
% INPUT
% data_type : {cell array of strings}
%             * see DOWNLOAD SOURCES for possible choices
% start     : datenum or datestr of year/month
% stop      : datenum or datestr of year/month
% directory : directory in which to store data; subdirectories will be
%             created for different data types
% 
% USAGE
% Download all Earthquake observations and all Visual observations from 2014
% >> download( {'EO', 'V'}, '2014/01', '2014/12')
%
% DOWNLOAD SOURCES
%   'EO'    : Earthquake Observations (non-located earthquake catalog)
%        'http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/data/vobs/   
%
%   'EV'    : Volcanic Earthquake Frequency Data (daily counts)
%       'http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/data/veq/'
%
%   'Tn'    : Tremor observations
%       'http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/data/vtr/'
%
%   'V'     : Visual Observations%   
%       'http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/data/enbo/'
%
%   'MONTHLY REPORT'
%           : PDF document of Monthly report
%       'http://www.data.jma.go.jp/svd/vois/data/tokyo/eng/volcano_activity/yyyy/yyyy_mm_monthly.pdf'
%
% SEE ALSO combinevolcano
%

%% SETUP

% JMA data url
base_url = 'http://www.data.jma.go.jp/svd/vois/data/tokyo/STOCK/bulletin/data/';

% if a 4th input variable is not provided, set directory to ''
if nargin < 4, directory = ''; end

%% DOWNLOAD

% loop through each data type and download all files
for n = 1:numel(data_type)
    
    [download_url, outputdir] = definePaths(base_url, data_type{n}, directory);
    
    % Download monthly report or download datafiles
    if strcmpi(data_type, 'MONTHLY REPORT')
        downloadreport(download_url, outputdir, start, stop);
    else
        downloaddata(download_url, outputdir, data_type{n}, start, stop);
    end

end

disp('Data download complete.')

%% Internal Functions

    % FUNCTION OUTPUTS
    % -ext_url : the url from which to grab data
    % -outdir  : the directory where downloaded data are stored (this is
    % created if necessary
    function [ext_url, outdir] = definePaths(base_url, data_type, directory)
        
        switch upper(data_type)
            
            case 'EO'
                ext_url = fullfile(base_url, 'vobs');
                outdir = fullfile(directory, 'obs');
                
            case 'EV'
                ext_url = fullfile(base_url, 'veq');
                outdir = fullfile(directory, 'veq');
                
            case 'TN'
                ext_url = fullfile(base_url, 'vtr');
                outdir = fullfile(directory, 'vtr');
                
            case 'V'
                ext_url = fullfile(base_url, 'enbo');
                outdir = fullfile(directory, 'enbo');
                
            case 'MONTHLY REPORT'            
                ext_url = 'http://www.data.jma.go.jp/svd/vois/data/tokyo/eng/volcano_activity/';
                outdir = fullfile(directory, 'volcano_activity');
                
            otherwise
                
                disp(['' data_type ''' is not a valid data type']);
                
        end
        
        % create the output directory, if necessary
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end
        
    end

    % subroutine that actually downloads the data
    function downloadreport(web_location, datadir, start, stop)
        
        warning('Only downloads files to the PWD')
        
        disp('Downloading data from:')
        disp(['  ' web_location ])
        
        start = datetime(datestr(start));
        stop =  datetime(datestr(stop));
        t = start;
        
        while t <= stop
            
            ds = datestr(t, 'yyyy_mm');
            filename = [ds '_monthly.pdf']; % filename syntax is 'yyyy_mm_monthly.pdf'
            outfilepath = fullfile(datadir, datestr(t, 'yyyy'), filename); % syntax is directory/yyyy/yyyy_mm_monthly.pdf
            
            % sometime the connection times out, so try 10 times before
            % giving up
            tries = 0;
            fprintf('Downloading report for %s...', ds);
            successful_download = 0;
            while tries <= 10
                
                try
                    
                    websave(filename, fullfile(web_location, datestr(t, 'yyyy'), filename));
                    successful_download = 1;
                    break;
                    
                catch
                    %
                end
                
                tries = tries+1;
                
            end
            
            if successful_download
                fprintf(' Download successful!\n')
            else
                fprintf(' No report available :-(\n');
            end
            t = t+calmonths(1);
            
        end
        
    end

    % subroutine that downloads monthly reports
    function downloaddata(web_location, datadir, type, start, stop)
        
        disp('Downloading data from:')
        disp(['  ' web_location ])
        
        start = datetime(datestr(start));
        stop =  datetime(datestr(stop));
        t = start;
        
        while t <= stop
            
            ds = datestr(t, 'yyyymm');
            filename = [type ds '.zip'];
            outfilepath = fullfile(datadir, filename);
            
            % sometime the connection times out, so try 10 times before
            % giving up
            tries = 0;
            while tries <= 10
                
                try
                    
                    disp(['Downloading ''' type ''' data for ' ds '...'])
                    websave(outfilepath, fullfile(web_location, filename));
                    unzip(outfilepath, datadir); delete(outfilepath);
                    break;
                    
                catch
                    disp(['No ''' type ''' data available for ' ds '.'])
                    % the html file name that will be created if no zip file is made
                    failedfile = fullfile(datadir, [filename '.html']);
                    delete(failedfile);
                end
                
                tries = tries+1;
                
            end
            t = t+calmonths(1);
            
        end
        
    end
        
    end
