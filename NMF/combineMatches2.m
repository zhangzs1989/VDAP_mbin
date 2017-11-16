function combineMatches2(inputs,params)

%{ 
THIS function reads in the match files for the templates and combines them
into one master catalog. It removes duplicates within given tolerance and
sorts output. Replaces clunky original code from SH
J. PESICEK
%}
warning('ON','all')

[template_numbers,~] = getTemplateInfo(params,inputs);

if isempty(template_numbers)
    return
end
%%
region=params.strRunName; % NOTE
outdir=[inputs.outDir,filesep,'NMF'];
outfile=fullfile(outdir,[region,'_NMFcatalog.txt']);
threshold=8; %only applied if higher than defined in NMFvars file

%Only keep events greater with correlation>min_threshold.
min_threshold=params.min_threshold; % NOTE

%JP: add new cull based on min channel count
minChan = params.minChan;

%% read in all matches for all templates
count=0;
for i=1:length(template_numbers)
    
    filename=[outdir,'/',region,'_NMFoutFile_templ',int2str(template_numbers(i)),'.txt']; % NOTE
    disp(filename)
    
    FID_results_1 = fopen(filename);
    if FID_results_1 == -1
        disp(filename)
        error(['Unable to open variable file '])
    end
    cross_corr_var_1 = textscan(FID_results_1, '%s', 'delimiter', '\n');
    fclose(FID_results_1);
    
    disp(['matches: ',int2str(length(cross_corr_var_1{1}))])
    for j=1:1:length(cross_corr_var_1{1})
            count=count+1;

            line=textscan(char(cross_corr_var_1{1}(j)),'%s %s %f %f %d %f', 'delimiter', ' ');
            match_time(count)=datenum([char(line{1}) ' ' char(line{2})]);
            catalog(count).ccc=line{3};%JP
            catalog(count).stc=double(line{5});%JP
            catalog(count).stdmc = double(line{6});
            catalog(count).ccm = double(line{4});
            catalog(count).templn = template_numbers(i);
            catalog(count).DateTime = datestr(match_time(count),'yyyy/mm/dd HH:MM:SS.FFF');
            catalog(count).Magnitude = line{3}; % use CCC for later preferred event in dup removal

    end
  
end
%% cull by thresholds
ccc = extractfield(catalog,'ccc');
ccm = extractfield(catalog,'ccm');
stc = extractfield(catalog,'stc');

I1 = ccc>=ccm*threshold;
I2 = ccc>=min_threshold;
I3 = stc>=minChan;

I = I1 & I2 & I3;

disp(['total NMF matches: ',int2str(count)])
disp(['removed by MAD  threshold: ',int2str(sum(~I1))])
disp(['removed by CCC  threshold: ',int2str(sum(~I2))])
disp(['removed by Chan threshold: ',int2str(sum(~I3))])
disp(['remaining: ',int2str(sum(I))])

match_time = match_time(I);
catalog = catalog(I);

[~,I] = sort(match_time);
match_time = match_time(I);
catalog = catalog(I);

%% now remove OT matches w/i threshold
catalog = rmDuplicateEvents(catalog,params.OTdiff);

%% print out
fid = fopen(outfile, 'w');
for i=1:numel(catalog)
    fprintf(fid,'%s %2.2f %4.3f %3i %2i %4.3f\n',catalog(i).DateTime,catalog(i).ccc,catalog(i).ccm,catalog(i).templn,catalog(i).stc,catalog(i).stdmc); %
end
fclose(fid);

end