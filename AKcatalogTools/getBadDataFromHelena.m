function baddata = getBadDataFromHelena( volcname, windows, varargin )
% GETBADDATAFROMHELENA Gets bad data days from Helena's object.
%
% INPUT:
% volcname 'string' -- volcano name to search for
% (optional) pathname 'string' -- path to Helena's file; otherwise default
% is used
% windows [n-by-2 double] -- a matrix of start/stop dates where start dates
% are in first column and stop dates are in second column
%
% OUTPUT:
% baddata [double] -- vector of datenums that are days with bad data
%
% USAGE
% >> baddata = getBadDataFromHelena('Pavlof', eruption_windows)
%
% >> baddata = getBadDataFromHelena('Pavlof', eruption_windows, '/Volumes/EFIS_seis/share/GOLD_STAR_FOR_HELENA/MONITOREDVOLCANO.mat');


%% Parse inputs and load data
% NOTE: Each volcno has a field called 'baddata' that is a list of days when the network is presumed to be down

switch nargin
    
    case 2
        
        load('/Volumes/EFIS_seis/share/GOLD_STAR_FOR_HELENA/MONITOREDVOLCANO.mat');
        
    case 3
        
        filepath = varargin{1};
        load(filepath)
        
    otherwise
        
        error('Too many inputs.')
        
end

%%

vnames = extractfield(VOLCANO,'name'); % extract names from Helena's object

% get volc coords
for i=1:size(vnames,2)
    TF = strcmp(volcname,vnames(i));
    if TF
        break
    end
end
if ~TF
    
    sprintf('NOTE: ''%s'' not found in Helena''s database. Script will proceed with no bad data days.',volcname);
    baddata = [];
    
else
    
    VOLCANO1 = VOLCANO(i); VOLCANO1.name;
    clear VOLCANO
    
    % get number of days of network down time
    ib = VOLCANO1.baddata > min(min(windows)) & VOLCANO1.baddata < max(max(windows)); % index of days when the network is down within time period of interest

    baddata = VOLCANO1.baddata(ib); % list of days when network is down within time period of interest
    
end;
%%
end