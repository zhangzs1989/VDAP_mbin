function doEruptons(AKeruptions,params,inputFiles,catalog,jiggle)

% we are just getting the volcano names to search over here:
I = find(cell2mat(AKeruptions(2:end,4)) ~= -1 & cell2mat(AKeruptions(2:end,3)) >= params.minVEI); %has network and VEI > X
I = I + 1; %FIX: adjust for header val
vnames = unique(AKeruptions(I,5));

disp([int2str(size(AKeruptions(I,5),1)),' Eruptions analyzed:'])
disp(strcat(datestr(cell2mat(AKeruptions(I,1))),' --> ',AKeruptions(I,5),' VEI: ',int2str(cell2mat(AKeruptions(I,3)))))

for n = 1:numel(vnames)
    %         volcname = char(AKeruptions(I(n),5));
    volcname = char(vnames(n));
    vinfo = getVolcanoSpecs(volcname,inputFiles,params);
    eruption_windows = getEruptionsFromSteph(volcname,AKeruptions,params.minVEI, false);
    AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
    
    if isempty(eruption_windows)
        sprintf('%s has no eruptions',params.volcanoes{n})
    end
    
end

end