%% ALASKA FALSE POSITIVES ANALYSIS
% Collects output data from all volcanoes and analyzes them as a whole
% produces eruptionData.mat file for each volcano

%% Load proper files

% KNOWN ISSUES: uses eruption-start in some cases where eruption-stop would
% be more appropriate, but is not yet available

[SUCCESS,MESSAGE,MESSAGEID] = mkdir(params.outDir);

% get all beta files from the output directory
files = subdir(fullfile(params.outDir, '*beta_output*'));

AKeruptions = readtext(inputFiles.Eruptions);

% load all beta_output variables
for n = 1:length(files) % cycle over volcanoes analyzed
    
    disp(files(n).name)
    load(files(n).name) % loads a variable named 'beta_output'
    si = strfind(files(n).name,filesep);
    volcname = files(n).name(si(end-1)+1:si(end)-1);
    
    %% send to external script for analysis
    
    % computes all statistics on when anomalies occur
    % and when first sustained anomaly occurred
    % this is done for each specific background window
    [beta_output, agg_data] = betaAnomalyTiming1A( beta_output ); %JW function
    
    %% JP
    % get start and stop anomaly times, excluding continued anomalies,
    % treating them as one.  I quadruple checked this and think is works
    for i=1:size(beta_output,2) %
        
        for k=1:size(beta_output(i).bin_sizes,2) % # of check sizes
            
            anomStartTimes = beta_output(i).t_checks(beta_output(i).is_over_beta(:,k),k);
            anomStopTimes = anomStartTimes + beta_output(i).bin_sizes(k);
            
            % treat consecutive anomalies as one
            anomStartTimes2 = anomStartTimes;
            anomStopTimes2 = anomStopTimes;
            
            for l=2:numel(anomStartTimes)
                
                ic = find(anomStartTimes(l) == beta_output(i).t_checks(:,k));
                if beta_output(i).is_over_beta(ic-1,k) % then it is a continued anomaly, don't double count
                    
                    anomStartTimes2 = setdiff(anomStartTimes2,anomStartTimes(l));
                    anomStopTimes2 = setdiff(anomStopTimes2,anomStopTimes(l-1));
                    
                end
                
            end
            
            % save reduced anomaly info
            beta_output(i).AnomStartTimes(k,:) = {anomStartTimes2};
            beta_output(i).AnomStopTimes(k,:)  = {anomStopTimes2};
            beta_output(i).AnomCount(k) = numel(anomStartTimes2);
            
        end
        
    end
    

    
    
    
    %% Now get total anomaly counts for each eruption
    % true and false positive rates for each volcano
    %{
    E.g., the variable beta_output, in this case, is supposed to be a
    1-by-n set of structures, where n is the number of background windows
    determined for a given volcano. nerupts is defined such that it looks
    through all n structures and determines how many of those background
    windows were terminated by an eruption (the alternative is that is was
    simply terminated by a bad network time).
    %}

    nerupts = sum(isfinite(unique(extractfield(beta_output,'next_eruption'))));      
    eruptionData = [];
    
    
        % JJW's notes:
    %{
    At this point, we have the start date for each anomaly/sustained
    anomaly (is this for one particular background window, or is this all of
    them for a given volcano. We also have the number of eruptions that have
    occurred for a given volcano.
    %}
    
    
    
    
    ii=0; % initialize incrementer
    for i=1:nerupts % for each eruption
        
        tp = []; fp = []; % true positives and false positives
        ii = ii + 1;

        anom_tot = 0;
        nanoms = zeros(3,1);
        
        t0 = beta_output(ii).start;
        t1 = beta_output(ii).next_eruption;
        t2 = beta_output(ii+1).next_eruption;
        
        for j=1:size(beta_output(ii).bin_sizes,2) % new eruption
            
            janoms1 = cell2mat(beta_output(ii).AnomStartTimes(j));
            janoms2 = cell2mat(beta_output(ii).AnomStopTimes(j));
            
            eruptionData(i).BeginAnomTimes(nanoms(j)+1:nanoms(j)+numel(janoms1),j) = janoms1;
            eruptionData(i).EndAnomTimes(nanoms(j)+1:nanoms(j)+numel(janoms2),j) = janoms2;
            
            nanoms(j) = nanoms(j) + numel(janoms1);
            
        end
        %%
        while t1 == t2 % test for same eruption or new one
            
            anom_tot = anom_tot + beta_output(ii).AnomCount;
            ii=ii+1;
            
            t1 = beta_output(ii).next_eruption;
            try
                t2 = beta_output(ii+1).next_eruption;
            catch
                t2 = NaN; % final pavlof eruption needs this, no events after
                continue
            end
            
            for j=1:size(beta_output(ii).bin_sizes,2)
                
                if ~isempty(cell2mat(beta_output(ii).AnomStartTimes(j)))
                    
                    janoms1 = cell2mat(beta_output(ii).AnomStartTimes(j));
                    janoms2 = cell2mat(beta_output(ii).AnomStopTimes(j));
                    
                    eruptionData(i).BeginAnomTimes(nanoms(j)+1:nanoms(j)+numel(janoms1),j) = janoms1;
                    eruptionData(i).EndAnomTimes(nanoms(j)+1:nanoms(j)+numel(janoms2),j) = janoms2;
                    
                    nanoms(j) = nanoms(j) + numel(janoms1);
                    
                end
                
            end
            
        end
        %%
        % now you are at the end of an eruption, accumulate stats
        anom_tot = anom_tot + beta_output(ii).AnomCount;
        
        eruptionData(i).EruptionIntervalStart = t0;
        eruptionData(i).EruptionStart = t1;
        eruptionData(i).nAnomalies = anom_tot;
        eruptionData(i).EruptionTrueDate = t1 - params.AnomSearchWindow;
        eruptionData(i).bin_sizes = beta_output(ii).bin_sizes;
        eruptionData(i).VEI = beta_output(ii).next_eruptionVEI;
        %NEW: check to see if t0 is after previous eruption repose
        %time
        
        if i==1
            %find previous eruption for repose time, whether monitored
            %or not
            eruption_windows = getEruptionsFromSteph(volcname,AKeruptions,params.minVEI,false);
            iep = find(eruption_windows(:,1)<t1, 1, 'last' );
            
            if ~isempty(iep)
                % if beta begin time earlier than last eruption + repose,
                % move begin time up to end of repose period
                t0r = datevec(eruption_windows(iep,2));
                tpe = t0r;
                t0r(1) = t0r(1) + params.repose;
                t0r = datenum(t0r);
            else
                t0r = datenum(1960,1,1); %default time to start counting repose years if prior eruption time not available: NOTE
                tpe = datevec(t0r);
            end
        else
            t0r = datevec(eruptionData(i-1).EruptionStart);
            tpe = t0r;
            t0r(1) = t0r(1) + params.repose;
            t0r = datenum(t0r);
        end
        
        for j=1:size(beta_output(ii).bin_sizes,2)
            
            
            if nnz(eruptionData(i).BeginAnomTimes(:,j)) > 0
                
                astarts = nonzeros(eruptionData(i).BeginAnomTimes(:,j));
                astops  = nonzeros(eruptionData(i).EndAnomTimes(:,j));
                
                % define true/false positives for the eruption
                ifp = astarts > t0r & astops <= t1 - params.AnomSearchWindow;
                %                 itp = astops > t1 - params.AnomSearchWindow & astarts < t1;
                itp = astops > t1 - params.AnomSearchWindow & astarts < t1 & astarts > t0r;
                
                
                % count tru/false positives
                tp(j) = sum(itp); if tp(j) > 1; tp(j) = 1; end; % don't count multiple TPs, just say yes once
                fp(j) = sum(ifp);
                
                eruptionData(i).FalsPosStart(j) = {astarts(ifp)};
                eruptionData(i).FalsPosStop(j)  = {astops(ifp) };
                
                eruptionData(i).TruePosStart(j) = {astarts(itp)};
                eruptionData(i).TruePosStop(j)  = {astops(itp) };
                
            else
                
                tp(j) = 0;
                fp(j) = 0;
                
                eruptionData(i).FalsPosStart(j) = {NaN};
                eruptionData(i).FalsPosStop(j) = {NaN};
                
                eruptionData(i).TruePosStart(j) = {NaN};
                eruptionData(i).TruePosStop(j) = {NaN};
            end
        end
        
        eruptionData(i).truePositives = tp;
        eruptionData(i).falsePositives = fp;
        eruptionData(i).t0_repose = t0r;
        eruptionData(i).yrsInRepose = etime(datevec(t1),tpe)/60/60/24/365; % years in repose
        % done accumulating stats, go to next eruption
    end
    
    %% now do time after last eruption.
    % This was an afterthought initially for new Pavlof eruption and recent Augustine data to see if there was an anomaly
    % have to treat it separately/differently since there is no eruption
    % afterward.  Probably a better way to design all this, but it's
    % working
    
    tp = []; fp = [];
    anom_tot = 0;
    nanoms = zeros(3,1);
    i=nerupts + 1;
    
    inan = find(isnan(extractfield(beta_output,'next_eruption')));
    if ~isempty(inan)
        t0 = beta_output(inan(1)).start;
        t1 = beta_output(inan(end)).stop;
        
        for ii = inan
            % could an eruption still occur withn preEruptionTimeWindow?
            
            for j = 1:size(beta_output(i).bin_sizes,2)
                
                janoms1 = cell2mat(beta_output(ii).AnomStartTimes(j));
                janoms2 = cell2mat(beta_output(ii).AnomStopTimes(j));
                
                eruptionData(i).BeginAnomTimes(nanoms(j)+1:nanoms(j)+numel(janoms1),j) = janoms1;
                eruptionData(i).EndAnomTimes(nanoms(j)+1:nanoms(j)+numel(janoms2),j) = janoms2;
                
                nanoms(j) = nanoms(j) + numel(janoms1);
                
            end
            
            anom_tot = anom_tot + beta_output(ii).AnomCount;
        end
        
        eruptionData(i).EruptionIntervalStart = beta_output(inan(1)).start;
        eruptionData(i).EruptionStart = NaN;
        eruptionData(i).nAnomalies = anom_tot;
        eruptionData(i).EruptionTrueDate = beta_output(inan(end)).stop - params.AnomSearchWindow;
        
        eruptionData(i).bin_sizes = beta_output(ii).bin_sizes;
        eruptionData(i).VEI = beta_output(ii).next_eruptionVEI;
        
        % t0r is essentially the time params.repose years after the start of the previous eruption
        t0r = datevec(eruptionData(end-1).EruptionStart); % datevec of the previous eruption
        t0r(1) = t0r(1) + params.repose; % add params.repose to the years column of the datevec
        t0r = datenum(t0r); % convert modified t04 to datenum
        
        % How to define a false positive:
        %{
        
  
           prev                                             this
         eruption                                         eruption
            ^                                                 ^  
            _                                                ___
           | |                 t0r                b         |   |      
        <--| |------------------|-----------------|---------|   |--> time
                                   false positive   true
                                   search window     pos
                                                    search
                                                    window

        
        where t0r == params.repose years after start of last eruption
              b   == params.AnomSearchWindow years before start of next eruption
              t1  == start of this eruption
        
        %}
        
        for j=1:size(beta_output(inan(end)).bin_sizes,2)
            
            if nnz(eruptionData(i).BeginAnomTimes(:,j)) > 0
                
                astarts = nonzeros(eruptionData(i).BeginAnomTimes(:,j)); % anomaly start times
                astops  = nonzeros(eruptionData(i).EndAnomTimes(:,j)); % anomaly stop times
                
                % Here's where we decide if a true positive or a false
                % positive occurred

                % is a flase positive if the following conditions are met:
                % (1) occurs in the time between params.repose years after the last eruption to params.AnomSearchWindow before the next eruption               
                ifp = astarts > t0r & astops <= t1 - params.AnomSearchWindow;
                
                % is a true positive if the following three conditions are met:
                % (1, 2) anomaly occurs within params.AnomSearchWindow years of the eruption
                % (3) astarts occurs params.repose years after the start of the last eruption
                itp = astops > t1 - params.AnomSearchWindow & astarts < t1 & astarts > t0r;
                
                tp(j) = sum(itp); if tp(j) > 1; tp(j) = 1; end; % don't count multiple TPs, just say yes once
                fp(j) = sum(ifp);
                
                eruptionData(i).FalsPosStart(j) = {astarts(ifp)};
                eruptionData(i).FalsPosStop(j) = {astops(ifp)};
                
                eruptionData(i).TruePosStart(j) = {astarts(itp)};
                eruptionData(i).TruePosStop(j) = {astops(itp)};
                
            else
                
                tp(j) = 0;
                fp(j) = 0;
                
                eruptionData(i).FalsPosStart(j) = {NaN};
                eruptionData(i).FalsPosStop(j) = {NaN};
                
                eruptionData(i).TruePosStart(j) = {NaN};
                eruptionData(i).TruePosStop(j) = {NaN};
                
            end
        end
        
        eruptionData(i).truePositives = tp;
        eruptionData(i).falsePositives = fp;
        eruptionData(i).t0_repose = t0r;
        eruptionData(i).yrsInRepose = etime(datevec(now),datevec(beta_output(inan(1)).start))/60/60/24/365; % years in repose
    end
    %%
    save([params.outDir,filesep,volcname,filesep,'eruptionData'],'eruptionData')
    
end % end compiling TP/FP info from beta_output > eruptionData.mat files

