function     einfo = getEruptionInfo(eruptionCat,ii)

% extract date times and coords from eruption catalog

einfo.StartDate = eruptionCat(ii).StartDate;
einfo.EndDate =  eruptionCat(ii).EndDate;
if isempty(einfo.EndDate)
    einfo.EndDate = datestr(datenum(einfo.StartDate) + 1);
end
einfo.VEI = eruptionCat(ii).VEI_max;
einfo.repose = eruptionCat(ii).repose_before_eruption;
einfo.eruptID = eruptionCat(ii).eruption_id;
einfo.name = char(extractfield(eruptionCat(ii),'volcano'));
einfo.Vnum = eruptionCat(ii).Vnum;
% vinfo.name = char(extractfield(eruptionCat(ii),'volcano'));
disp([einfo.name,', ',(einfo.StartDate)])
%     disp(' ')

% if nargout == 2
%     if ~isempty(volcanoCat)
%         % now find matching coords in volcanoCat
%         vid = eruptionCat(ii).Volcano_ID;
%         vids= extractfield(volcanoCat,'Volcano_ID');
%         
%         iv = find(vid == vids);
%         
%         [vinfo] = getVolcanoInfo(volcanoCat,[],iv);
%         if isempty(iv)
%             error('No match')
%         end
%     else
%         vinfo = getVolcanoInfoFromNameOrNum(einfo.name);
%     end
%     varargout{1} = vinfo;
% end

end