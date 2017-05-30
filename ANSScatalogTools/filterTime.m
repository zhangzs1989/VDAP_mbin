function [ out_catalog ] = filterTime( in_catalog, varargin )
%FILTERTIME Filters the ANSS catalog based on time
% This function is meant to be used with the ANSS catalog. It is meant to
% be used after the catalog has already been imported and saved as a
% structure. It can filter between two given dates. Alternatively, it can
% keep or remove all events on a specified matrix of dates. See the
% Usage examples below for assumed inputs.
%
% INPUT:
% - in_catalog = {struct} an ANSS catalog imported to Matlab and stored as a
% structure
% - {variable input arguments} see Usage examples below
%
% OUTPUT
% - out_catalog = {struct} a smaller version of the input catalog that is
% filtered to the time ranges specificed
%
% USAGE
% BETWEEN TWO DATES
% >> % filter a catalog to events that occurred in March 2014
% >> subcatalog = filterTime( original_catalog, datenum('2014/03/01 00:00:00'), datenum('2014/03/31 23:59:59'));
%
% BETWEEN VECTOR OF DATES
% >> % filter a catalog to events that occured in March 2013, March 2014, or May 2014
% >> starts = {'2013/03/01 00:00:00','2014/03/01 00:00:00','2014/05/01 00:00:00'}
% >> stops = {'2013/03/31 23:59:59','2014/03/31 23:59:59','2014/05/31 23:59:59'}
% >> subcatalog = filterTime(catalog, starts, stops)
%
% KEEP EVENTS
% >> % filter a catalog to keep events that occured on given dates
% >> dates_of_interest = datenum('2014/03/01'):datenum('2014/03/31')
% >> subcatalog1 = filterTime( original_catalog, 'keep', dates_of_interest );
%
% REMOVE EVENTS
% >> % filter a catalog to remove events that occured on given dates
% dates_of_interest = datenum('2014/03/01'):datenum('2014/03/31')
% >> subcatalog2 = filterTime ( original_catalog, 'remove', dates_of_interest);
% >> % From the previous two examples, the answer to the following statement should be 1:
% >> numel(catalog) == numel(subcatalog1) + numel(subcatalog2)


%{
(most of this is already covered in the USAGE given above)
EXAMPLE:

Import all events from March 2013, March 2014, and May 2014 by giving
FILTERTIME start and stop dates for those windows.

>> catalog -> import an ANSS catalog
>> starts = {'2013/03/01 00:00:00','2014/03/01 00:00:00','2014/05/01 00:00:00'}
>> stops = {'2013/03/31 23:59:59','2014/03/31 23:59:59','2014/05/31 23:59:59'}
>> subcat = filterTime5C(catalog, starts, stops)

NOTE: The following definitions for start dates (e.g.) are all equivalent:
starts = {'2013/03/01 00:00:00','2014/03/01 00:00:00','2014/05/01 00:00:00'}
starts = {'2013/03/01 00:00:00';'2014/03/01 00:00:00';'2014/05/01 00:00:00'}
starts = datenum({'2013/03/01 00:00:00','2014/03/01 00:00:00','2014/05/01 00:00:00'})
starts = datenum({'2013/03/01 00:00:00';'2014/03/01 00:00:00';'2014/05/01 00:00:00'})

%}


%
% see also IMPORTANSSCATALOG, FILTERANNULUS, FILTERDEPTH

% AUTHOR: Jay Wellik & Jeremy Pesicek, USGS-USAID Volcano Disaster Assistance Program
% CONTACT: jwellik-usgs.gov; johnwellikii-gmail.com
% DATE: 2015-Sep

% UPDATES
%{
2015-Nov-06: Remove events from a certain date [jp]
2015-Nov-09: Expand JP's improvements to work with 'varargin' ability [jjw]
2015-Nov-09: Changed the logical operators to '>=' and '<='; previously,
the operators were not inclusive. This shouldn't affect much because the
precision of dates given was usually down to the second. [jjw]
2015-Nov-16: Allow start and stop times to be vectors
%}
%%

% get event times from the catalog - returned in Matlab date format
if ~isempty(in_catalog)
    
    DateTime = datenum(extractfield(in_catalog, 'DateTime'));
    
    % assumes on of the following
    % (1) varargin{1} is 'keep' or 'remove', and varargin{2} is a vector
    % of dates. In this case, varargin{1} is of 'char' variable type
    % (2) varargin{1} is a vector of start dates, and varargin{2} is a
    % vector of stop dates. Together, they define windows of data that you want
    % to keep. In this case, varargin{1} is not of 'char' variable type.
    
    if ischar(varargin{1})
        
        switch varargin{1}
            
            case 'keep'
                
                on_given_day_index = getIndexForEventsOnDate( varargin, DateTime );
                disp([int2str(sum(on_given_day_index)),' events to ' varargin{1} '.'])
                out_catalog = in_catalog(logical(on_given_day_index)); % keep only the dates that were entered
                
            case 'remove'
                
                on_given_day_index = getIndexForEventsOnDate( varargin, DateTime );
                disp([int2str(sum(on_given_day_index)),' events to ' varargin{1} '.'])
                out_catalog = in_catalog(~logical(on_given_day_index)); % remove the entered dates
                
            otherwise
                
                error('FILTERTIME did not understand your input.')
                
        end
        
    else
        
        t1 = datenum(varargin{1}); % start of filtering time window
        t2 = datenum(varargin{2}); % stop of filtering time window
        
        id_t = zeros(size(DateTime)); % initialize indices of times as zeros
        for n = 1:length(t1)
            
            id_t = id_t + ((DateTime >= t1(n) & DateTime <= t2(n))); % % returns the index for all events inbetween t1 and t2 (JP: speed up)
            
        end
        
        out_catalog = in_catalog(logical(id_t));     % Subselection of data within the time window
        
        
    end
  
else
    out_catalog = in_catalog;
end

%% LOCAL FUNCTIONS

    function [on_given_day_index] = getIndexForEventsOnDate( original_varargin, DateTime )
        
        date_list = original_varargin{2}; % second input variable is the matrix of dates you want to keep or remove
        date_list = datenum(date_list); % ensure dates are datenum variable type
        
        on_given_day_index = zeros(length(DateTime),1); % initialize indices for targeted dates
        
        for i=1:length(date_list)
            
            day = floor(date_list(i)); % the dates that are in the list (make sure its precision is a day)
            
            % find events in catalog on that day
            I = floor(DateTime) == day;
            on_given_day_index = on_given_day_index + I;
            
        end
        
    end

end