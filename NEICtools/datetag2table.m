function T = datetag2table( event_time, tag, varargin )
%DATETAG2TABLE Uses an array of event times, channel tags, and pick times
%to create a table of events that can be used with the NEIC Subspace
%Detector
%   tag can either by a single ChannelTag - in which case the same
%   ChannelTag is assigned to every event - or it can be an array of
%   ChannelTags that is the same length as event_time.

% T = cfgtable;
T = table;
if ~isempty(event_time)
    
    if nargin==3, pick_time = varargin{1}; else pick_time = []; end
    
    for n = 1:numel(event_time)
        %
        %         T{n, 'dn1'} = event_time(n);
        %         T.dt1(n) = NaT;
        %         T.dt1(n) = datetime(datestr(T{n, 'dn1'}));
        %
        if numel(tag)==1
            tn = 1;
        elseif numel(tag)==numel(event_time)
            tn = n;
        else
            error('Tag must be a single ChannelTag or be the same length as event_time.')
        end
        
        %
        
        %
        %         % default table values;
        %         T.lat(n) = 0;
        %         T.lon(n) = 0;
        %         T.depth(n) = 0;
        %         T.mag(n) = 1;
        %         T.mag_type(n) = {'m'};
        %         T.phase(n) = {'P'};
        
        dn1 = event_time(n);
        dt1 = datetime(datestr(dn1));
        T{n, 'dn1'} = dn1;
        T{n, 'dt1'} = dt1;
        T{n, 'lat'} = 0;
        T{n, 'lon'} = 0;
        T{n, 'depth'} = 0;
        T{n, 'mag'} = 0;
        T{n, 'mag_type'} = {'m'};
        T.N(n) = {tag(tn).network};
        T.S(n) = {tag(tn).station};
        T.C(n) = {tag(tn).channel};
        lstr = strrep(tag(tn).location, ' ', ''); % replace blank spaces in location string with empty spaces
        if isempty(lstr)
            T.L(n) = {'..'};
        else
            T.L(n) = {tag(tn).location};
        end
        T{n, 'phase'} = {'P'};
        if numel(pick_time)==0
            dn2 = dn1;
            dt2 = dt1;
        elseif numel(pick_time)==numel(event_time)
            dn2 = pick_time(n);
            dt2 = datetime(datestr(dn2));
        else
            error('pick_time must be a empty or be the same length as event_time.')
        end
        T{n, 'dn2'} = dn2;
        T{n, 'dt2'} = dt2;
        
    end
end

T;

end

