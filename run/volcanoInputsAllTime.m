%% AK Catalog Analysis
% This file does...
% (1) Loads the inputFiles struct and the params struct
% (2) Loads the earthquake catalog 
% (3) Loads and initializes all volcano-specific information for the
% anlaysis (i.e., eruption_times, volcano-specific modifications to the
% params structure, etc.).

%%

clearvars -except startUpLocs catalog jiggle

%% LOAD INPUTFILES AND PARAMS VARIABLES FROM .MAT FILES

load(startUpLocs.inputFiles); % path to inputFiles.mat
load(startUpLocs.params); % path to params.mat

%% LOAD catalogs
if ~exist('catalog','var')
    disp('loading catalog...')
    load(inputFiles.catalog);
    disp('...catalog loaded')
end

if ~exist('jiggle','var') && params.jiggle
    disp ('loading jiggle...')
    load(inputFiles.jiggle);
    disp('...jiggle loaded')
else
    jiggle = [];
end

%% START VOLCANOES

    % temporary warning for user
try
    params.volcanoes;
catch
   error('The params structure must now include a variable called ''volcanoes''. See the ''PARAMS'' block of ex_paramsvolcanoes.m for assistance. This warning will go away after a few weeks (posted Th Jan 7, 2016).')
end   


for n = 1:numel(params.volcanoes)
    
    switch params.volcanoes{n};
        
        case 'Spurr'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [datenum('June 27, 1992') datenum('November 9, 1992')];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            
        case 'Shishaldin'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [ ... 
                datenum('December 23, 1995') datenum('December 24, 1995'); ...
                datenum('June 2, 1997') datenum('June 2, 1997'); ...
                datenum('February 9, 1999') datenum('May 28, 1999'); ...
                datenum('February 17, 2004') datenum('May 17, 2004'); ...
                datenum('January 28, 2014') datenum('January 28, 2014'); ...
                ];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            
        case 'Cleveland'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [ ... 
                datenum('1984/07/12') datenum('1984/07/13'); ...
                datenum('1985/12/10') datenum('1985/12/12'); ...
                datenum('1986/04/28') datenum('1986/05/27'); ...
                datenum('1987/06/19') datenum('1987/08/28'); ...
                datenum('1989/10/22') datenum('1989/10/28'); ...
                datenum('1994/05/25') datenum('1994/05/26'); ...
                datenum('1997/05/05') datenum('1997/05/05'); ...
                datenum('2001/02/02') datenum('2001/04/15'); ...
                datenum('2005/04/27') datenum('2005/09/27'); ...
                datenum('2006/02/06') datenum('2006/02/06'); ...
                datenum('2006/05/23') datenum('2006/05/24'); ...
                datenum('2006/08/24') datenum('2006/10/28'); ...
                datenum('2007/07/01') datenum('2009/01/23'); ...
                datenum('2009/06/25') datenum('2009/06/26'); ...
                datenum('2009/10/02') datenum('2009/12/12'); ...
                datenum('2010/05/30') datenum('2010/06/01'); ...
                datenum('2011/07/16') datenum('2013/02/15'); ...
                datenum('2013/05/04') datenum('2014/03/06'); ...
                datenum('2014/06/05') datenum('2015/07/15'); ...
                ];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            
            
        case 'Veniaminof'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [...
                datenum('2002/09/28 00:00:00') datenum('2003/03/23 00:00:00');...
                datenum('2004/02/19 00:00:00') datenum('2004/09/01 00:00:00');...
                datenum('2005/01/04 00:00:00') datenum('2005/02/25 00:00:00');...
                datenum('2005/09/07 00:00:00') datenum('2005/11/04 00:00:00');...
                datenum('2006/03/03 00:00:00') datenum('2006/06/05 00:00:00');...
                datenum('2008/02/22 00:00:00') datenum('2008/03/04 00:00:00');...
                datenum('2009/01/08 00:00:00') datenum('2009/10/19 00:00:00');...
                datenum('2013/06/13 00:00:00') datenum('2013/10/11 00:00:00');...
                ];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            %%
            
        case 'Redoubt'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [ ...
                datenum('1989/12/14') datenum('1990/06/30'); ...
                datenum('2009/03/15 13:05:00')+(8/24) datenum('2009/07/01'); ...
                ];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            %%
            
        case 'Kanaga'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [...
                datenum('2012/02/17 00:00:00') datenum('2012/02/19 00:00:00'); ...
                ];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            %%
            
        case 'Augustine'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [ ...
                datenum('2005/12/02') datenum('2006/03/31'); ...
                ];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            %%
            
        case 'Pavlof'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [ ...
                datenum('2007/08/13') datenum('2007/09/13'); ...
                datenum('2013/05/13') datenum('2013/07/08'); ...
                datenum('2014/05/31') datenum('2014/06/25'); ...
                datenum('2014/11/12') datenum('2014/11/25'); ...
                ];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            %%
            
        case 'Okmok'

            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [...
                datenum('2008/07/12 11:43:00')+(8/24) datenum('2008/11/01:00:00')];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            %%
            
        case 'Ahmanilix'
            
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [...
                datenum('2008/07/12 11:43:00')+(8/24) datenum('2008/11/01:00:00')];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            %%
            
        case 'Kasatochi'
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            
            eruption_windows = [ datenum('2008/08/07 14:01:00')+(8/24) datenum('2008/09/14')];
            
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            %%
            
        case 'Semisopochnoi'
            volcname = params.volcanoes{n};
            vinfo = getVolcanoSpecs(volcname,inputFiles,params);
            eruption_windows = [];
            AlaskaVolcanoPlots(vinfo,eruption_windows,params,inputFiles,catalog,jiggle)
            
            %%
            
        otherwise
            
            error('%s is not a volcano defined in the volcanoInputsAllTime.m file.',params.volcanoes{n}) 
            
    end
    if strcmp(params.visible,'off')
        close all
    end
end
