function [E,ie] = addEinfo2event(eqtime,estarts,estops,eruptIDs)

dayLags = estarts-floor(eqtime); % this makes eqs on eruption day to have zero lag.
I = (ceil(eqtime) <= estops & floor(eqtime) > estarts); %those during eruption
si = sign(dayLags)>=0; % includes those events on eruption day
[Y,~] = min(dayLags(si));

%%
if ~isempty(Y)
    ie = dayLags==Y;
    E.EruptID = eruptIDs(ie); %eruptionCat(ie(ei)).eruption_id;
    E.DayLag = Y;
else
    E.EruptID = NaN;
    E.DayLag = NaN;
    ie = [];
end

E.coEruptive = sum(I);

end