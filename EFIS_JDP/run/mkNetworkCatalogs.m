
% J. PESICEK Winter 2016/17

clearvars -except catalog

%% READ inputs
input.catalog = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/getISCcat3/iscCatalogAll4wFMs.mat'; % importISCcatalog.m
input.catStrName='ISC';
input.catalogsDir = '/Users/jpesicek/Dropbox/Research/EFIS/ISC/NetworkCatalogs'; % importISCcatalog.m

%% set up diary
[~,~,~] = mkdir(input.catalogsDir);
diaryFileName = [input.catalogsDir,filesep,datestr(now,30),'_diary.txt'];
diary(diaryFileName);
disp(mfilename('fullpath'))
disp(' ')
disp(input)
disp(' ')

%% LOAD catalog
if ~exist('catalog','var') %&& isstruct(catalog)
    disp('loading catalog...')
    load(input.catalog); %created using importISCcatalog.m
    %     [ catalog ] = filterDepth( catalog, params.DepthRange(2)); % (d)
    %     [ catalog ] = filterMag( catalog, params.MagRange(1) ); % (e)
    %     [ catalog ] = filterTime( catalog, datenum('1990/01/01'), params.catalogEndDate); % start here to cut out redoubt for now
    disp('...catalog loaded')
end

AUTHOR = extractfield(catalog,'AUTHOR');
MagAUTHOR = extractfield(catalog,'MagAUTHOR');

if ~strcmp(char(AUTHOR),char(MagAUTHOR))
    warning('hypocenter and magnitude authors not the same')
end

uAUTHOR = unique(AUTHOR);

%% NOW get and save network catalogs
for i=1:numel(uAUTHOR)
    disp([int2str(i),'/',int2str(numel(uAUTHOR)),': ',char(uAUTHOR(i))])
    
    outCatName=fullfile(input.catalogsDir,char(uAUTHOR(i)));
    
    if ~exist([outCatName,'.mat'],'file')
        
        index = structfind(catalog,'AUTHOR',uAUTHOR{i}); %ISC
        catalog_s = catalog(index);
        save(outCatName,'catalog_s');
        disp([int2str(numel(index)),' events'])
        
        if ~isempty(catalog_s)
            % make kml file
            kmlName=[input.catStrName,'_catalog_',uAUTHOR{i}];
            try
                mkKMLfileFromCatalog(catalog_s,fullfile(input.catalogsDir,kmlName));
            catch
                warning('KML file trouble')
            end
            
        end
        
        mags = extractfield(catalog_s,'Magnitude');
        dtimes = datenum(extractfield(catalog_s,'DateTime'));
        t1 = min(dtimes); t2 = max(dtimes);
        
        %make b-value plot
        [F, H, b, Mc, Stats] = Gutenberg(mags,0.25,2,100);
        set(get(H(1),'title'),'String',[uAUTHOR{i},' Magnitudes (',int2str(length(mags)),' events)'])
        if any(~isnan(Mc))
            set(get(H(2),'title'),'String',['Gutenberg-Richter from ',datestr(t1,23),' to ',datestr(t2,23)])
        end
        print(F,'-dpng',fullfile(input.catalogsDir,['Gutenberg_',uAUTHOR{i}]))
        McData(i)=struct('Source',uAUTHOR(i),'Mc',Mc,'bvalue',b,'t1',datestr(t1,23),'t2',datestr(t2,23),'nevents',length(mags),'Stats',Stats);
        close(F)
        
    else
        disp('skip repeat')
    end
end
%%
save(fullfile(input.catalogsDir,['Mc_',input.catStrName]),'McData')
diary OFF
