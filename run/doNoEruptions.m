function doNoEruptions(AKeruptions,params,inputFiles,catalog,jiggle)

load(inputFiles.HB);
vnames2 = extractfield(VOLCANO,'name');
vnames2 = sort(vnames2');
disp([int2str(numel(vnames2)),' volcanoes monitored according to HB, testing all...'])
clear VOLCANO

% remove ones with eruptions with VEI > minVEI
I = find(cell2mat(AKeruptions(2:end,4)) ~= -1 & cell2mat(AKeruptions(2:end,3)) >= params.VEI); %has network and VEI > X
I = I + 1; %FIX: adjust for header val
vnames = unique(AKeruptions(I,5));
vnames3 = setdiff(vnames2,vnames); % remainder of volcanoes monitored but with no eruptions

% do remaining volcanoes
for n =1 :numel(vnames3)
    volcname = char(vnames3(n));
    vinfo = getVolcanoSpecs(volcname,inputFiles,params);
    eruption_windows = [];
    AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
end


end
