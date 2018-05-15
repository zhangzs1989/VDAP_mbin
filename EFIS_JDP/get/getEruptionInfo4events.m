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
            %             edata(ii).VEI = einfo(l).VEI;
            %             edata(ii).repose = einfo(l).repose;
            
            %             edata(ii).name = einfo(l).name;
            edata(ii).eruptID = einfo(l).eruptID;
            edata(ii).Vnum = einfo(l).Vnum;
        end
        
    end
    
    if ~isempty(edata)
        
        eqtime = datenum(catalog(j).DateTime);
        estarts=datenum(extractfield(edata,'StartDate'));
        estops= datenum(extractfield(edata,'EndDate'));
        eruptIDs= extractfield(edata,'eruptID');
        
        [E,ie] = addEinfo2event(eqtime,estarts,estops,eruptIDs);
        
        %         dayLags = estart-floor(eqtime); % this makes eqs on eruption day to have zero lag.
        %         I = (ceil(eqtime) <= estop & floor(eqtime) > estart); %those during eruption, but not on eruption day
        %         si = sign(dayLags) >= 0; % includes those events on eruption day, which I consider Pre-eruptive
        %         [Y,~] = min(dayLags(si));
        %
        %         if ~isempty(Y)
        %             ie = dayLags==Y; % index of soonest eruption after event
        %             catalog(j).EruptID = edata(ie).eruptID;
        %             catalog(j).DayLag = Y; % lag from event to eruption, zero means on same day, but assume before
        %         else % no eruptions following, all before
        %             catalog(j).EruptID = NaN;
        %             catalog(j).DayLag = NaN;
        % %             catalog(j).coEruptive = NaN;
        %         end
        %
        %         catalog(j).coEruptive = sum(I);%those during eruption, but not on eruption day
        
        fn = fieldnames(E);
        for ii=1:numel(fn)
            catalog(j).(fn{ii}) = E.(fn{ii});
        end
        
        if isempty(ie)
            continue
        end
        %% add all fields to output line
        vinfo = getVolcanoInfoFromNameOrNum(edata(ie).Vnum,volcanoCat_j);
        try
            vinfo = rmfield(vinfo,{'Latitude','Longitude','elevs'});
        end
        fn = fieldnames(vinfo);
        for ii=1:numel(fn)
            catalog(j).(fn{ii}) = vinfo.(fn{ii});
        end
        %%
        [ARCLEN, AZ] = distance(catalog(j).Latitude,catalog(j).Longitude,vinfo.lat,vinfo.lon);
        catalog(j).dist = deg2km(ARCLEN);
        catalog(j).azi = AZ;
    else
        catalog(j).coEruptive = 0;
        catalog(j).DayLag = NaN;
        catalog(j).EruptID = NaN;
    end
    
    
end


end