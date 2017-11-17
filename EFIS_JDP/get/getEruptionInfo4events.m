function [ catalog ] = getEruptionInfo4events(catalog,volcanoCat,eruptionCat,radius)

% This finds the closest eruption in time following the event w/i the given
% radius and adds eruption fields to event catalog

for j=1:numel(catalog)
    
    disp(['    ',int2str(j)])
    volcanoCat_j = filterAnnulusm(volcanoCat,catalog(j).Latitude,catalog(j).Longitude,radius); % all volcs w/i radius
    
    %     figure, worldmap('world')
    %     load coast
    %     plotm(lat,long,'g');
    %     plotm(extractfield(catalog,'Latitude'),extractfield(catalog,'Longitude'),'b.')
    %     plotm(extractfield(volcanoCat_j,'Latitude'),extractfield(volcanoCat_j,'Longitude'),'r.')
    
    catalog(j).eruptID = NaN;
    catalog(j).DayLag = NaN;
    catalog(j).coEruptive = NaN;
    
    if isempty(volcanoCat_j)
        continue
    end
    
    edata = [];
    
    for i=1:numel(volcanoCat_j)
        einfo = getEruptionInfoFromNameOrNum(volcanoCat_j(i).Vnum,eruptionCat); % eruption info for each volc
        
        ii=0;
        for l=1:length(einfo)
            ii = ii + 1;
            edata(ii).StartDate=(einfo(l).StartDate);
            if isempty(einfo(l).EndDate)
                edata(ii).EndDate=datestr(datenum(einfo(l).StartDate)+1);
            else
                edata(ii).EndDate=(einfo(l).EndDate);
            end
            edata(ii).VEI = einfo(l).VEI;
            edata(ii).eruptID = einfo(l).eruptID;
            edata(ii).repose = einfo(l).repose;
            
            edata(ii).name = einfo(l).name;
            edata(ii).Vnum = einfo(l).Vnum;
        end
        
    end
    
    if ~isempty(edata)
        eqtime = datenum(catalog(j).DateTime);
        estart=datenum(extractfield(edata,'StartDate'));
        estop= datenum(extractfield(edata,'EndDate'));
        dayLags = estart-floor(eqtime); % this makes eqs on eruption day to have zero lag.
        I = (eqtime <= estop & ceil(eqtime) > estart); %those during eruption, but not on eruption day
        si = sign(dayLags)>-1; % includes those events on eruption day, which I consider Pre-eruptive
        [Y,~] = min(dayLags(si));
        
        % NOTE: GVP has no eruption times, only dates!!
        % Thus, ASSUME that if an event is on the day of the eruption, that it
        % is a precursor to the eruption. Only count it once as preEruptive,
        % not also synEruptive
        
        if ~isempty(Y)
            ie = dayLags==Y; % index of soonest eruption after event
            catalog(j).eruptID = edata(ie).eruptID;
            catalog(j).DayLag = Y; % lag from event to eruption, zero means on same day, but assume before
        else % no eruptions following, all before
            continue
        end
        catalog(j).coEruptive = sum(I);%those during eruption, but not on eruption day
        catalog(j).name = edata(ie).name;
        catalog(j).Vnum = edata(ie).Vnum;
        
        %         disp(edata(ie))
        % add volcano fields?
        vinfo = getVolcanoInfoFromNameOrNum(edata(ie).Vnum,volcanoCat_j);
        
        catalog(j).composition = vinfo.composition;
        catalog(j).type = vinfo.type;
        catalog(j).tectonic = vinfo.tectonic;
        [ARCLEN, ~] = distance(catalog(j).Latitude,catalog(j).Longitude,vinfo.lat,vinfo.lon);
        catalog(j).dist = deg2km(ARCLEN);
    end
end


end