function combineMatches2(params,inputs)

%{

%}
warning('ON','all')

if ~isfield(params,'templates2run')
    template_numbers = [];    
elseif strcmpi(params.templates2run,'none')
    template_numbers = [];
elseif strcmpi(params.templates2run,'all')
    [qmllist,result] = readtext(inputs.quakeMLfileList,',','#');
    template_numbers = cell2mat(qmllist(:,1));
else
    template_numbers = params.templates2run;
end

if isempty(template_numbers)
    return
end

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
            ccc(count)=line{3};%JP
            stc(count)=double(line{5});%JP
            stdmc(count) = double(line{6});
            ccm(count) = double(line{4});
            templn(count) = template_numbers(i);
            catalog(count).DateTime = datestr(match_time(count),'yyyy/mm/dd HH:MM:SS.FFF');
            catalog(count).Magnitude = ccc(count); % use CCC for later preferred event in dup removal

    end
  
end
%% cull by thresholds
I1 = ccc>=ccm*threshold;
I2 = ccc>=min_threshold;
I3 = stc>=minChan;

I = I1 & I2 & I3;
match_time = match_time(I);
ccc = ccc(I);
stc = stc(I);
stdmc = stdmc(I);
ccm = ccm(I);
catalog = catalog(I);
templn = templn(I);

[~,I] = sort(match_time);
match_time = match_time(I);
ccc = ccc(I);
stc = stc(I);
stdmc = stdmc(I);
ccm = ccm(I);
catalog = catalog(I);
templn = templn(I);

%% now remove OT matches w/i threshold

I = findDuplicateEvents(catalog,params.OTdiff/86400);
I = ~I;
match_time = match_time(I);
ccc = ccc(I);
stc = stc(I);
stdmc = stdmc(I);
ccm = ccm(I);
catalog = catalog(I);
templn = templn(I);

%% print out
fid = fopen(outfile, 'w');
for i=1:numel(catalog)
    fprintf(fid,'%s %2.2f %4.3f %3i %2i %4.3f\n',datestr(match_time(i)),ccc(i),ccm(i),templn(i),stc(i),stdmc(i)); %
end
fclose(fid);

end