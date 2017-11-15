%% MAIN code to run the Network Matched Filter
clear
tic

inputFile = '/Users/jpesicek/VDAP_mbin/NMF/NMF_input.txt';
[inputs,params] = getInputFiles(inputFile);
[~,~,~] = mkdir(fullfile(inputs.outDir));

diaryFileName = fullfile(inputs.outDir,['/NMF_',datestr(now,30),'_diary.txt']);
diary(diaryFileName);
disp(datetime)
details(inputs)
details(params)

%% read in quakeml files and prepare templates for NMF
[NMFeventFile, NMFoutFile, template_numbers]=getTemplates(inputs,params);

%% Now do NMF
if ~isempty(template_numbers)
    
    runNMF(inputs,params,NMFeventFile,NMFoutFile)
    
    %% Now combine all matches for all templates into one catalog removing repeats
    combineMatches(params,inputs)
    
    %% plot
    plotNMFresults(inputs,params)
end

toc
diary OFF