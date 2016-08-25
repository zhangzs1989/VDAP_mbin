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

if ~iscell(params.volcanoes)
    
    switch params.volcanoes % do all from steph's list
        
        case 'Erupt'
            
            doEruptons(AKeruptions,params,inputFiles,catalog,jiggle)
            
        case 'NoErupt'
            
            doNoEruptions(AKeruptions,params,inputFiles,catalog,jiggle)
            
        case 'All'
            
            doEruptons(AKeruptions,params,inputFiles,catalog,jiggle)
            doNoEruptions(AKeruptions,params,inputFiles,catalog,jiggle)         
            
        otherwise
            
            error('Need string input option or cell list of volcanoes')
            
    end
else
    
    % use user list of volcanoes
    
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
