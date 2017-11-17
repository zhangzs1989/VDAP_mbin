function [result,status,offenderCountries,offenderVolcanoes,I] = checkCatalogDBintegrity(dbPath,volcanoCat)
warning('on','all')

cheader = {'volcano','dir','ISC','ISC Mc','ANSS','local','local Mc','MASTER','MASTER Mc','JMA'};

checks = zeros(numel(cheader)-1,numel(volcanoCat));
for i=1:numel(volcanoCat)
    
    vpath = fullfile(dbPath,fixStringName(volcanoCat(i).country),fixStringName(volcanoCat(i).Volcano));
    
    checks(1,i) = exist(vpath,'dir');
    Vnum = volcanoCat(i).Vnum;
    catNames{1,:} = vpath;
    
    catNames{2,:} = ['ISC_',int2str(Vnum),'.mat'];
    catNames{3,:} = ['Mc/ISC_McInfo_',int2str(Vnum),'.mat'];
    catNames{4,:} = ['ANSS_',int2str(Vnum),'.mat'];
    catNames{5,:} = ['local_',int2str(Vnum),'.mat'];
    catNames{6,:} = ['Mc/local_McInfo_',int2str(Vnum),'.mat'];
    catNames{7,:} = ['MASTER_',int2str(Vnum),'.mat'];
    catNames{8,:} = ['Mc/MASTER_McInfo_',int2str(Vnum),'.mat'];
    catNames{9,:} = ['JMA_',int2str(Vnum),'.mat'];
    
    for j=2:numel(catNames)
        checks(j,i) = exist(fullfile(vpath,catNames{j}),'file');
    end

end

tmp=[ extractfield(volcanoCat,'Volcano'); num2cell(checks)];
result = [cheader',tmp];
%%
status = zeros(numel(catNames),2);
I = zeros(size(checks,2),length(status));
for i=1:length(status)
    I(:,i) = checks(i,:)==0;
    if sum(I(:,i)) == 0
        status(i,1) = 1;
    else
        
    end
    status(i,2) = sum(~I(:,i))/length(I(:,i));
    disp([num2str(sum(~I(:,i)),'%04d'),'/',num2str(length(I(:,i)),'%04d'),' (',num2str(sum(~I(:,i))/length(I(:,i))*100,'%05.1f'),'%) ',cheader{i+1}])
end
%%
cs = [];
vs = [];
for i=[1:3 7:8] % check only cheader columns that all volcanoes should have (excluding ANSS, JMA, local)
    Ii = checks(i,:)==0;
    if status(i,1)==0
        cs=[cs; extractfield(volcanoCat(Ii),'country')'];
        vs=[vs; extractfield(volcanoCat(Ii),'Volcano')'];
    end
end
offenderCountries=unique(cs);
offenderVolcanoes=unique(vs);
%% MAKE QC fig?

end