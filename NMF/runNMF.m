%% MAIN code to run the Network Matched Filter
clear

inputFile = '/Users/jpesicek/VDAP_mbin/NMF/NMF_input.txt';
[inputs,params] = getInputFiles(inputFile);
[~,~,~] = mkdir(fullfile(inputs.outDir));
diaryFileName = fullfile(inputs.outDir,['/NMF_',datestr(now,30),'_diary.txt']);

%% read in quakeml files and prepare templates for NMF
[NMFeventFile,template_numbers]=getTemplates(inputs,params);

%% Now do NMF
if ~isempty(template_numbers)
    
    tic
    diary(diaryFileName);
    disp(datetime)
    details(inputs)
    details(params)
    
    NMF(inputs,params,NMFeventFile)
    
    %% Now combine all matches for all templates into one catalog removing repeats
    combineMatches2(inputs,params)
    
    %% plot
    plotNMFresults(inputs,params)
    
    plotNMFhelicorders(inputs,params,'TMKS_EHZ_VG')
    toc
end

diary OFF