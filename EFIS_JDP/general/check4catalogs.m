function [status,catNames,varargout]= check4catalogs(vpath,Vnum,localCatPath)

cats = {...
    'ISC',...
    'GEM',...
    'MASTER',...
    'FINAL',...
    'ANSS',...
    'Comcat'...
    'GNS',...
    'JMA',...
    'BMKG',...
    'SSN',...
    'SIL',...
    'IGN',...
    'INGV',...
    'local',...
    };
%%
ncats = length(cats);

if isnumeric(Vnum)
    
    % all appropriately named files:
    D = dir2(vpath,['*_',int2str(Vnum),'.mat']);
    
    for i=1:ncats
        catNames{i,:} = ['cat_',cats{i},'_',int2str(Vnum),'.mat'];
        %     catNames(i,:) = catName(i);
    end
    
    if isempty(D)
        for i=1:ncats
            status(i) = false;
        end
        return
    else
        [C,IA] = setdiff(extractfield(D,'name'),['vinfo_',int2str(Vnum),'.mat']);
        status(1) = exist(fullfile(localCatPath,catNames{i}),'file');
        for i=2:ncats
            status(i) = exist(fullfile(vpath,catNames{i}),'file');
        end
    end
    
    if length(C) > length(status)
        C2 = setdiff(catNames,C);
        warning('unexpected catalog: ')
        disp(C2)
    end
    
elseif isstruct(Vnum) %volcanoCat
    
    volcanoCat = Vnum;
    checks = zeros(ncats+1,numel(volcanoCat));
    dbPath = vpath;
    
    for i=1:numel(volcanoCat)
        
        vpath = fullfile(dbPath,fixStringName(volcanoCat(i).country),fixStringName(volcanoCat(i).Volcano));
        checks(1,i) = exist(vpath,'dir');
        Vnum = volcanoCat(i).Vnum;

        for ii=1:ncats
            catNames{ii,:} = ['cat_',cats{ii},'_',int2str(Vnum),'.mat'];
            %     catNames(i,:) = catName(i);
        end
        
        for j=1:numel(catNames)
            checks(j+1,i) = exist(fullfile(vpath,catNames{j}),'file');
        end
        
    end
    
    tmp=[ extractfield(volcanoCat,'Volcano'); num2cell(checks)];
    cheader = ['volcano','dir',cats];
    result = [cheader',tmp];
    %%
    status = zeros(numel(catNames)+1,2);
    I = zeros(size(checks,2),length(status));
    for i=1:length(status)
        I(:,i) = checks(i,:)==0;
        if sum(I(:,i)) == 0
            status(i,1) = 1;
        else
            
        end
        status(i,2) = sum(~I(:,i))/length(I(:,i));
        disp([num2str(sum(~I(:,i)),'%04d'),'/',num2str(length(I(:,i)),'%04d'),...
            ' (',num2str(sum(~I(:,i))/length(I(:,i))*100,'%05.1f'),'%) ',cheader{i+1}])
    end
    %%
    cs = [];   vs = [];
    for i=[1:4] % check only cheader columns that all volcanoes should have (excluding ANSS, JMA, local)
        Ii = checks(i,:)==0;
        if status(i,1)==0
            cs=[cs; extractfield(volcanoCat(Ii),'country')'];
            vs=[vs; extractfield(volcanoCat(Ii),'Volcano')'];
        end
    end
    offenderCountries=unique(cs);
    offenderVolcanoes=unique(vs);
    varargout{1} = result;
    varargout{2} = offenderCountries;
    varargout{3} = offenderVolcanoes;
    varargout{4} = I;
end

end