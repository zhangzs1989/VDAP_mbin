function doIntrusions(params,inputFiles,catalog,jiggle)

AKintrusions = readtext(inputFiles.Intrusions);
% AKintrusions(1,6) = {'start_str'};
% AKintrusions(1,7) = {'stop_str'};
% for i=2:size(AKintrusions,1)
%     AKintrusions(i,6) = {datestr(cell2mat(AKintrusions(i,1)))};
%     AKintrusions(i,7) = {datestr(cell2mat(AKintrusions(i,2)))};
% end

% codes in file are a bit arbitrary
% -1 is cited but not useable
%  0 is only one swarm cited, so unclear if it is intrusion related swarm or precursory DVT swarm to intrusion
%  1 is two swarms cited with 2nd swarm inferred as intrusion

% we are just getting the volcano names to search over here:
I = find(cell2mat(AKintrusions(2:end,3)) ~= -1);

I = I + 1; %FIX: adjust for header val
vnames = unique(AKintrusions(I,4));

disp([int2str(size(AKintrusions(I,5),1)),' Intrusions analyzed:'])
disp(strcat(datestr(datenum(num2str(cell2mat(AKintrusions(I,1))),'yyyymmdd')),' --> ',AKintrusions(I,4)))

for n = 1:numel(vnames)
    %         volcname = char(AKintrusions(I(n),5));
    clear intrusion_windows
    volcname = char(vnames(n));
    II = find(strcmp(volcname,AKintrusions(:,4)));
    vinfo = getVolcanoSpecs(volcname,inputFiles,params);
    for i=1:numel(II)
        intrusion_windows(i,1) = datenum(num2str(cell2mat(AKintrusions(II(i),1))),'yyyymmdd');
        intrusion_windows(i,2) = datenum(num2str(cell2mat(AKintrusions(II(i),2))),'yyyymmdd');
        intrusion_windows(i,3) = 999; % set VEI for intrusion
        intrusion_windows(i,4) = cell2mat(AKintrusions(II(i),6)); %Mc
        intrusion_windows(i,5) = cell2mat(AKintrusions(II(i),7)); % repose
    end
    AlaskaVolcanoPlots(vinfo,intrusion_windows,params,inputFiles,catalog,jiggle)

    if isempty(intrusion_windows)
        sprintf('%s has no intrusions',params.volcanoes{n})
    end
    
end

end