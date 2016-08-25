function [stats] = getBetaOutStats(params)
%% get and save Be value table
stats(1,1)={'Volcano'};

for i=1:numel(params.ndays_all)
    stats(1,1+i) = {['Be (',int2str(params.ndays_all(i)),' day win)']};
    
    for v= 1:numel(params.volcanoes)
        
        files(v) = subdir(fullfile(params.outDir, params.volcanoes{v}, '*beta_output*'));
        disp(files(v).name)
        load(files(v).name) % loads a variable named 'beta_output'
        si = strfind(files(v).name,filesep);
        volcname = files(v).name(si(end-1)+1:si(end)-1);
        stats(v+1,1) = {volcname};
        stats(v+1,i+1) = {beta_output(1).Be(i)};
        
        
    end
end

s6_cellwrite(fullfile(params.outDir,'BetaEvals.csv'),stats);

end

