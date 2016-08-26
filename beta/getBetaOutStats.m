function [stats] = getBetaOutStats(params,inputFiles)
%% get and save Be value table for all results
stats(1,1)={'Volcano'};
files = dir2(params.outDir, '-r', '*beta_output*');
AKeruptions = readtext(inputFiles.Eruptions);
stats(1,5)={'Eruption?'};

for i=1:numel(params.ndays_all)
    stats(1,1+i) = {['Be (',int2str(params.ndays_all(i)),' day win)']};
    
    for v= 1:numel(files)
        
        disp(files(v).name)
        file = fullfile(params.outDir,files(v).name);
        load(file) % loads a variable named 'beta_output'
        si = strfind(file,filesep);
        volcname = file(si(end-1)+1:si(end)-1);
        stats(v+1,1) = {volcname};
        stats(v+1,i+1) = {beta_output(1).Be(i)};
        if sum(strcmp(volcname,AKeruptions(:,5)))>0
            stats(v+1,numel(params.ndays_all)+2) = {1};
        else
            stats(v+1,numel(params.ndays_all)+2) = {0};
        end
        
    end
end

end

