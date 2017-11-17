function [status,catNames]= check4catalogs(vpath,Vnum,localCatPath)


% all appropriately named files:
D = dir2(vpath,['*_',int2str(Vnum),'.mat']);

% expected files
iscname = ['ISC_',int2str(Vnum),'.mat'];
ansname = ['ANSS_',int2str(Vnum),'.mat'];
locname = ['local_',int2str(Vnum),'.mat'];
masname = ['MASTER_',int2str(Vnum),'.mat'];
jmaname = ['JMA_',int2str(Vnum),'.mat'];

catNames{1,:} = iscname;
catNames{2,:} = ansname;
catNames{3,:} = locname;
catNames{4,:} = masname;
catNames{5,:} = jmaname;

if isempty(D)
    status(1) = 0;
    status(2) = 0;
    status(3) = 0;
    status(4) = 0;
    status(5) = 0;
    return
else
    % remove vinfo file
    [C,IA] = setdiff(extractfield(D,'name'),['vinfo_',int2str(Vnum),'.mat']);
    
    status(1) = exist(fullfile(vpath,catNames{1}),'file');
    status(2) = exist(fullfile(vpath,catNames{2}),'file');
    status(3) = exist(fullfile(localCatPath,catNames{3}),'file');
    status(4) = exist(fullfile(vpath,catNames{4}),'file');
    status(5) = exist(fullfile(vpath,catNames{5}),'file');
end
if length(C) > length(status)
    C2 = setdiff(catNames,C);
    warning('unexpected catalog: ')
    disp(C2)
end


end

