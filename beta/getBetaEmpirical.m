function [ BE, P , background_T, background_N] = getBetaEmpirical( window_type, eventtimes, windows , params, vinfo )
% function [ BE, P , background_T, background_N] = getBetaEmpirical( window_type, eventtimes, windows , ndays, it, be_thresPer )

disp(mfilename('fullpath'))
%GETBETAEMPIRICAL Calculates empirical beta given a defined background
%window.

%{
INPUT

WINDOW_TYPE 'string' - defined as 'all,' 'individual,' or 'past';
-'all' means you use all background periods to calculate empirical beta
-'individual' means you calculate a new empirical beta for each background
window
-'past' means you calculate a new empirical beta for each background window
but you use everything from the past including previous background windows
up to that point

EVENTTIMES - vector of doubles that is already filtered to match the
windows.

WINDOWS - an n-by-2 (or 2-by-n) matrix representing start and stop times
for the background window

NDAYS - vector of doubles that represents a series of short term time
window lengths that you want to test

BE_THRESPER - double

OUTPUT

BE - Empirical beta values for each window of size ndays. Should be same
size as ndays

P - 

BACKGROUND_T - Amount of time to be used as background

BACKGROUND_N - Number of events in background


author: Jeremy Pesicek and Jay Wellik, US Geological Survey, Volcano
Disaster Assistance Program

%}

%% SETUP

    % ensure that 'eventtimes' represents datenums of double type
datenum(eventtimes);

    % temporary hard coding of time to consider background
% start_time = params.betaBackgroundType(1);
start_time = vinfo.NetworkStartDay;
cut_off_time = params.betaBackgroundType(2); %JP: end of current network health analysis

eventtimes = eventtimes(eventtimes >= start_time & eventtimes < cut_off_time);
disp(['NOTE -- # of events in beta background catalog (before ' datestr(cut_off_time,'mmm dd, yyyy') '): ' num2str(numel(eventtimes)) ])

ndays = params.ndays_all;
it = params.it;
be_thresPer = params.be_thresPer;

%% Switches between different time definitions of background

switch window_type
    
    case 'all'
        
        [BE, P, background_N, background_T] = calculateForAllWindows( eventtimes, windows, ndays, it, be_thresPer );
        
    case 'individual'
        
        error('Calculate Empirical Beta for Each Window: This feature is not yet available :-(')
        [BE, P] = calculateForIndWindows();
        
        
    case 'past'
        
        error('Calculate Empirical Beta for Past Data: This feature is not yet available :-(')
        [BE, P] = calculateForPastWindows();
        
    otherwise
        
        error('The function did not understand how you want to define the time period for background.')
        
end


%%

        % creates a gapless time window from the entire data set such that
        % many iterations can be run over all of the data that are
        % considered background in order to calculate empirical data
    function [be, p, N, T] = calculateForAllWindows( eventtimes, windows, ndays, it, be_thresPer )
        
        
        accumulated_time = 0; % initialize total amount of time being used for empirical beta
        relative_time = eventtimes; % initialize times of events relative to the gapless window
        
        for n = 1:size(windows,1) % for each background window
            
           window_start = windows(n,1); % start of window
           window_stop = windows(n,2); % stop of window
           id = (eventtimes >= datenum(windows(n,1)) & eventtimes <= datenum(windows(n,2))); % index of all events in that window
           relative_time(id) = accumulated_time + ( eventtimes(id) - window_start ); % append timing of events relative to gapless time window
           accumulated_time = accumulated_time + (window_stop - window_start); % update the amount of accumulated time in the gapless time window
            
        end
        
        [be, p, N, T] = calculateEmpiricalBeta( relative_time, ndays, it, be_thresPer ); % pass the gapless time series to the function

    end


    function calculateForIndWindows( eventtimes, windows, ndays, it, be_thresPer )
        calculateEmpiricalBeta( eventtimes, windows, ndays, it, be_thresPer );
    end


    function calculateForPastWindows( eventtimes, windows, ndays, it, be_thresPer )
        calculateEmpiricalBeta( eventtimes, windows, ndays, it, be_thresPer );
        
    end


        % generic process of calculating empircal beta value
    function [be, p, background_N, background_T] = calculateEmpiricalBeta( datetime, ndays, it, be_thresPer)
        
        % if there are no events, set results to nan and notify theuser
        if isempty(datetime)
            
            display('NOTE: No events in catalog. Empirical beta value is NAN.');
            be = nan(size(ndays)); p = nan(size(ndays));
            
        else
            
            for n = 1:length(ndays)
                
                
                % define variables for beta test
                N = length(datetime); % number of events in entire time period
                T = datetime(end) - datetime(1); % length of entire time period
                Ta = ndays(n); % length of study time period
                % Na (defined later) = number of events in study time period
                
                % define random time windows
%                 randtime = datetime(1) + (n) + (datetime(end)-(datetime(1)+ndays(n))).*rand(it,1); % the end of the test window; creates a set of it random times between t1 and t2 where t1 is ndays after the first event and t2 is the last event (see Matlab doc)
                randtime = datetime(1)+ndays(n):datetime(end); % remove randomness, not needed (JP)
                it = length(randtime);
                br(it) = zeros; % empirical beta calculated for each iteration
                bet = 2.57; % 2-sigma theoretical threshold
                
                for i=1:it
                    
                    t_rand = randtime(i);
                    t_checkr = t_rand - ndays(n); %
                    id = find(datetime > t_checkr & datetime < t_rand);
                    Na = length(id);
                    br(i) = betas(Na, N, Ta, T); %
                    
                    clear t_rand t_checkr id Na
                    
                end % end i
                
                p(n) = size(br(br>bet),2); % initialize percent of trials above 95% or 2-sigma
                p(n) = p(n)/it*100; % percent of trials above 95% or 2-sigma
                
                brs = sort(br,'descend');
                be(n) = brs(round(be_thresPer*it)); % empirical threshold as defined by SP triggering study
                
                background_N(n) = N;
                background_T(n) = T;
                clear N T Ta randtime br bet brs
                
            end % end n
            
        end % end if
        
    end % end calculateBetaEmpirical

end % end :-)