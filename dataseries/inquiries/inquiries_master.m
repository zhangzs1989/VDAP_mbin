%% INQUIRIES

%% #1 - Post-eruptive Swarms
%
% What percentage of eruptions
%     of VEI size V or greater
%     that are not followed by another eruption within Y years
% are followed by dVT swarms
%     within D months of the last eruption?
%
% INPUT: 
%   -> UnitedStates_explosions1.m
%   -> analyze4Anomalies.m
%   -> log2Elog.m

V = [2 3];
Y = [1:10];
D = [1:60];

for n = 1:height(ELOG)
    if ~isempty(ELOG(n,:).post_sanom{1}.start),
        time2nxtanom(n,1) = datenum(min(ELOG(n,:).post_sanom{1}.start)) - datenum(ELOG(n,:).stop);
    else
        time2nxtanom(n,:) = NaN;
    end
end
ELOG.time2nxtanom = time2nxtanom;

for y = 1:numel(Y)
    for d = 1:numel(D)
        a = ELOG;
        a(a.time2nxt < Y(y)*365 | isnan(a.time2nxt), :) = [];
        Na = height(a);
        
        b = a;
        b(b.time2nxtanom > D(d) | isnan(b.time2nxtanom), :) = [];
        Nb = height(b);

        fprintf('Y = %i | D = %i -- %i of %i (%2.1f%%) eruptions are followed by an anomaly.\n', Y(y), D(d), Nb, Na, Nb/Na*100);
    end
end

%% #2 - Intra-eruptive Dome Destroying Eruptions
%{
What percentage of dome destroying eruptions
    of VEI size V or greater
    that occur after R days of repose
are preceded by seismic rate anomalies,
    as defined by a W day window,
    within D days of the eruption?
%}

