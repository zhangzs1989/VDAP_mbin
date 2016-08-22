%% AK Catalog Analysis
% This file does...
% (1) Loads the inputFiles struct and the params struct
% (2) Loads the earthquake catalog
% (3) Loads and initializes all volcano-specific information for the
% anlaysis (i.e., eruption_times, volcano-specific modifications to the
% params structure, etc.).

%%

%% START VOLCANOES

% temporary warning for user
try
    params.volcanoes;
catch
    error('The params structure must now include a variable called ''volcanoes''. See the ''PARAMS'' block of ex_paramsvolcanoes.m for assistance. This warning will go away after a few weeks (posted Th Jan 7, 2016).')
end

AKeruptions = readtext(inputFiles.Eruptions);
AKeruptions(1,6) = {'start_str'};
AKeruptions(1,7) = {'stop_str'};
for i=2:size(AKeruptions,1)
    AKeruptions(i,6) = {datestr(cell2mat(AKeruptions(i,1)))};
    AKeruptions(i,7) = {datestr(cell2mat(AKeruptions(i,2)))};
end

if isempty(params.volcanoes) % do all from steph's list
    
    % we are just getting the volcano names to search over here:
    I = find(cell2mat(AKeruptions(2:end,4)) ~= -1 & cell2mat(AKeruptions(2:end,3)) >= params.minVEI); %has network and VEI > X 
    I = I + 1; %FIX: adjust for header val
    vnames = unique(AKeruptions(I,5));
    
    disp([int2str(size(AKeruptions(I,5),1)),' Eruptions analyzed:'])
    disp(strcat(datestr(cell2mat(AKeruptions(I,1))),' --> ',AKeruptions(I,5)))
    
    for n = 1:numel(vnames)
%         volcname = char(AKeruptions(I(n),5));
        volcname = char(vnames(n));
        vinfo = getVolcanoSpecs(volcname,inputFiles,params);
        eruption_windows = getEruptionsFromSteph(volcname,AKeruptions,params.minVEI,true);
        AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)

        if isempty(eruption_windows)
            sprintf('%s is not currently defined',params.volcanoes{n})
        end
       
    end

else % use user list of volcanoes
    
    for n = 1:numel(params.volcanoes)
        
        volcname = params.volcanoes{n};
        vinfo = getVolcanoSpecs(volcname,inputFiles,params);
        eruption_windows = getEruptionsFromSteph(volcname,AKeruptions,params.minVEI,true);
        AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
        
        if isempty(eruption_windows)
            sprintf('%s is not currently defined',params.volcanoes{n})
        end
        
    end
    
end

if strcmp(params.visible,'off')
    close all
end
