function [stats] = getAnomOutStats(params,inputFiles)
%% get and save Be value table for all results
stats(1,1)={'PosBcBeRatio'};
stats(1,3)={'TF'};
stats(1,2)={'Volcano'};
stats(1,4)={'BetaWindowSize'};
stats(1,5)={'MaxStartTime'};
stats(1,6)={'1stStartTime'};
% stats(1,6)={'Be'};
stats(1,7)={'EruptionStart'};
% files = dir2(params.outDir, '-r', '*beta_output*');

% get eruptionData.mat files from JP FalsePositives.m code run post
% analysis
files = dir2(params.outDir, '-r', '*eruptionData.mat');

AKeruptions = readtext(inputFiles.Eruptions);
% stats(1,5)={'Eruption?'};
    count = 1;

for w=1:numel(params.ndays_all) % loop over beta window sizes
    
    %     stats(1,1+i) = {['Be (',int2str(params.ndays_all(i)),' day win)']};
    
    for v= 1:numel(files)
        
        disp(files(v).name)
        file = fullfile(params.outDir,files(v).name);
        %         load(files(v).name) % loads a variable named 'beta_output'
        load(file)
        
        si = strfind(file,filesep);
        volcname = file(si(end-1)+1:si(end)-1);
        
        %loop over eruptions
        nerupts = sum(isfinite(unique(extractfield(eruptionData,'EruptionStart'))));
        
        %how many with long enough repose?
        reposes = extractfield(eruptionData,'yrsInRepose'); % including those after last eruption
        ereposes = extractfield(eruptionData(1:end-1),'yrsInRepose'); %only those before eruptions
        
        ir = find(reposes > params.repose);
        %         eir= (ereposes > params.repose);
        
        %which VEIs to plot
        VEI = extractfield(eruptionData,'VEI');
        et  = extractfield(eruptionData,'EruptionStart');
        
        if ~isempty(ir) && sum(VEI>=params.VEI(1)) > 0
            
            %             %         nerupts = sum(ir); %size(eruptionData,2) - 1;
            %             fps = (extractfield(eruptionData(ir),'falsePositives'));
            %             tps = (extractfield(eruptionData(ir),'truePositives'));
            %
            %             fpMaxBc = (extractfield(eruptionData(ir),'FalsPosMaxVals'));
            %             tpMaxBc = (extractfield(eruptionData(ir),'TruePosMaxVals'));
            
            for k=1:numel(ir)
                
                fpMaxBcs = cell2mat(eruptionData(k).FalsPosMaxVals(w));
                tpMaxBcs = cell2mat(eruptionData(k).TruePosMaxVals(w));
                
                fpMaxBcsT = cell2mat(eruptionData(k).FalsPosMaxStart(w));
                tpMaxBcsT = cell2mat(eruptionData(k).TruePosMaxStart(w));                

%                 fp1stT = cell2mat(eruptionData(k).FalsPosStart(w));
                tp1stT = cell2mat(eruptionData(k).TruePosStart(w));                
                
                for fp=1:find(~isnan(fpMaxBcs))
                    count = count + 1;
                    stats(count,1) = {fpMaxBcs(fp)};
                    stats(count,2) = {volcname};
                    stats(count,3) = {'FP'};
                    stats(count,4) = {params.ndays_all(w)};
                    stats(count,5) = {datestr(fpMaxBcsT(fp),'yyyy-mm-ddTHH:MM:SS')};
                end
%                 for fp=1:find(~isnan(fp1stT))
%                     stats(count,6) = {datestr(fp1stT(fp),'yyyy-mm-ddTHH:MM:SS')};
% %                     stats(count,7) = {datestr(et(fp),'yyyy-mm-ddTHH:MM:SS')};
%                 end
                    
                for tp=1:find(~isnan(tpMaxBcs))
                    count = count + 1;
                    stats(count,1) = {tpMaxBcs(tp)};
                    stats(count,2) = {volcname};
                    stats(count,3) = {'TP'};
                    stats(count,4) = {params.ndays_all(w)}; 
                    stats(count,5) = {datestr(tpMaxBcsT(tp),'yyyy-mm-ddTHH:MM:SS')};   
                end
                for tp=1:find(~isnan(tp1stT))
                    stats(count,6) = {datestr(tp1stT(tp),'yyyy-mm-ddTHH:MM:SS')};                    
                    stats(count,7) = {datestr(et(tp),'yyyy-mm-ddTHH:MM:SS')};                             
                end
            end
            %             for e=1:nerupts
            %                 %loop over TPs
            %                 nTPs = eruptionData(e).truePositives(w);
            %                 nFPs = eruptionData(e).falsePositives(w);
            %
            %                 if nTPs > 0
            %                     for tp = 1%:nTPs
            %                         count = count + 1;
            %                         stats(count,1) = {max(cell2mat(eruptionData(e).TruePosPeak(w,tp)))};
            %                         stats(count,2) = {volcname};
            %                         stats(count,3) = {1};
            %                     end
            %                 end
            %                 if nFPs > 0
            %                     for fp = 1:nFPs
            %                         count = count + 1;
            %                         stats(count,1) = {max(cell2mat(eruptionData(e).FalsPosPeak(w,fp)))};
            %                         stats(count,2) = {volcname};
            %                         stats(count,3) = {0};
            %                     end
            %                 end
            %
        end
        % now do period after last eruption
        
    end
end

end

