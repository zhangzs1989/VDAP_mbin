function combineMatches(params,inputs)

%%%This program combines individual results files into one catalog.
%%%Individual matches cannot be within within_seconds, or they are treated
%%%as the same match, and only the best (by correlation value)one is kept.
%%% sourced from S. Holtkamp
%%% some modifications by J. Pesicek  NOTE: THIS NEEDS WORK!!

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
%%
%First template, to initialize results matrix
first_template=template_numbers(1);
template_to_test=first_template;
within_seconds=params.OTdiff;
region=params.strRunName; % NOTE
outdir=[inputs.outDir,filesep,'NMF'];
outfile=fullfile(outdir,[region,'_NMFcatalog.txt']);
filename_1=[outdir,'/',region,'_NMFoutFile_templ',int2str(first_template),'.txt']; % NOTE
filename_2=[outdir,'/',region,'_NMFoutFile_templ',int2str(first_template),'.txt']; % NOTE
template_range = template_numbers; % NOTE

%%Two ways to cull results below: daily MAD, or constant min_threshold

%Only keep events which matched better than threshold*MAD
threshold=8; %only applied if higher than defined in NMFvars file

%Only keep events greater with correlation>min_threshold.
min_threshold=params.min_threshold; % NOTE

%JP: add new cull based on min channel count
minChan = params.minChan;

%Lines below to line 100 initialize the results matrix.
FID_results_1 = fopen(filename_1);
if FID_results_1 == -1
    disp(filename_1)
    error(['Unable to open variable file '])
end
cross_corr_var_1 = textscan(FID_results_1, '%s', 'delimiter', '\n');
fclose(FID_results_1);
match_time_1=[];
ccc_1=[];
count=0;
cullMAD=0; %JP
cullCCC=0; %JP
cullChan=0; %JP
for each_line_1=1:1:length(cross_corr_var_1{1})
    line_1=textscan(char(cross_corr_var_1{1}(each_line_1)),'%s %s %f %f %d %f', 'delimiter', ' ');
    if((line_1{3}<line_1{4}*threshold))
        cullMAD = cullMAD + 1;
        continue
    end
    if((line_1{3}<min_threshold))
        cullCCC = cullCCC + 1;
        continue
    end

    if((line_1{5}<minChan))%JP
        cullChan = cullChan + 1;
        continue
    end
    
    count=count+1;
    match_time_1(count)=datenum([char(line_1{1}) ' ' char(line_1{2})]);
    ccc_1(count)=line_1{3};%JP
    stc_1(count)=double(line_1{5});%JP

%     ccc_1(count)=double(line_1{3})/double(line_1{5});%JP test normalize ccc by stc
    
end
%JP
disp(['total NMF matches: ',int2str(length(cross_corr_var_1{1}))])
disp(['removed by MAD  threshold: ',int2str(cullMAD)])
disp(['removed by CCC  threshold: ',int2str(cullCCC)])
disp(['removed by Chan threshold: ',int2str(cullChan)])
disp(['remaining: ',int2str(length(cross_corr_var_1{1})-cullMAD-cullCCC-cullChan)])

FID_results_2 = fopen(filename_2);
if FID_results_2 == -1
    error(['Unable to open variable file '])
end
cross_corr_var_2 = textscan(FID_results_2, '%s', 'delimiter', '\n');
fclose(FID_results_2);
match_time_2=[];
ccc_2=[];
count=0;
cullMAD=0;%JP
cullCCC=0;%JP
cullChan=0;%JP
for each_line_2=1:1:length(cross_corr_var_2{1})
    line_2=textscan(char(cross_corr_var_2{1}(each_line_2)),'%s %s %f %f %d %f', 'delimiter', ' ');
    if((line_2{3}<line_2{4}*threshold))
        cullMAD = cullMAD + 1;
        continue
    end
    if((line_2{3}<min_threshold))        
        cullCCC = cullCCC + 1;
        continue
    end
    
    if((line_2{5}<minChan))%JP
        cullChan = cullChan + 1;
        continue
    end
    
    count=count+1;
    match_time_2(count)=datenum([char(line_2{1}) ' ' char(line_2{2})]);
    ccc_2(count)=line_2{3};%JP
    stc_2(count)=double(line_2{5});%JP
    
%     ccc_2(count)=double(line_2{3})/double(line_2{5});%JP test normalize ccc by stc
    
end
disp(['total NMF matches: ',int2str(length(cross_corr_var_2{1}))])
disp(['removed by MAD  threshold: ',int2str(cullMAD)])
disp(['removed by CCC  threshold: ',int2str(cullCCC)])
disp(['removed by Chan threshold: ',int2str(cullChan)])
disp(['remaining: ',int2str(length(cross_corr_var_2{1})-cullMAD-cullCCC-cullChan)])

new_matches=[];
ids=[];
%combine the catalogs
for i=1:1:length(match_time_2)
    if(~sum(find(abs((match_time_2(i)-match_time_1)*86400)<within_seconds)))
        new_matches(i,:)=[match_time_2(i), ccc_2(i), template_to_test, stc_2(i)];
    else
        first_file_id=find(abs((match_time_2(i)-match_time_1)*86400)<within_seconds);
        ids=[ids;first_file_id'];
        switch_on_this=ccc_1(first_file_id)>ccc_2(i);
        switch switch_on_this  % JP: DNW on more than 2 repeats!!
            case 1
                new_matches(i,:)=[match_time_1(first_file_id), ccc_1(first_file_id), first_template, stc_1(first_file_id)];
            case 0
                
                new_matches(i,:)=[match_time_2(i), ccc_2(i), template_to_test, stc_2(i)];
        end
    end
end
possible_ids=1:1:length(match_time_1);
orig_ids=find(~ismember(possible_ids,ids));
%new_matches
new_matches=sortrows([new_matches;[match_time_1(orig_ids)', ccc_1(orig_ids)', first_template*ones(length(orig_ids),1), stc_1(orig_ids)']]);
fid = fopen(outfile, 'w');
fclose(fid);

fid = fopen(outfile, 'a');
fprintf(fid, '%6.11f %2.2f %3i %d\n', new_matches'); %
fclose(fid);

% {
%%%%%%%%%%Every Other Template. You can skip bad templates here. 
%%%NOTE: JP not updated!!
for template_to_test=[template_range(2:end)'];%NOTE!!!!!
    try
        file_to_write=outfile;
        
        %filename_2=['earthquake_results_' region '_temp2.txt'];
        
        FID_results_1 = fopen(file_to_write);
        if FID_results_1 == -1
            warning(['Unable to open variable file '])
        end
        cross_corr_var_1 = textscan(FID_results_1, '%s', 'delimiter', '\n');
        match_time_1=[];
        ccc_1=[];
        count=0;
        for each_line_1=1:1:length(cross_corr_var_1{1})
            line_1=textscan(char(cross_corr_var_1{1}(each_line_1)),'%f %f %f %d');
%             line_1=textscan(char(cross_corr_var_1{1}(each_line_1)),'%s %s %f %f %d %f', 'delimiter', ' ');


            count=count+1;
            match_time_1(count)=line_1{1};
%             match_time_1(count)=datenum([char(line_1{1}) ' ' char(line_1{2})]);

            ccc_1(count)=line_1{2};%JP
            stc_1(count)=double(line_1{4});%JP
            first_template(count)=line_1{3};
        end
        FID_results_2 = fopen([outdir,filesep,region,'_NMFoutFile_templ' num2str(template_to_test) '.txt'],'r');
        if FID_results_2 == -1
            error(['Unable to open variable file '])
        end
        cross_corr_var_2 = textscan(FID_results_2, '%s', 'delimiter', '\n');
        fclose(FID_results_2);
        match_time_2=[];
        ccc_2=[];
        count=0;
        cullMAD=0;%JP
        cullCCC=0;%JP
        cullChan=0;%JP
        for each_line_2=1:1:length(cross_corr_var_2{1})
            line_2=textscan(char(cross_corr_var_2{1}(each_line_2)),'%s %s %f %f %d %f', 'delimiter', ' ');
%             if(line_2{3}<line_2{4}*threshold)
%                 continue
%             end
%             
%             if((line_2{3}<min_threshold))
%                 continue
%             end
%             
            if((line_2{3}<line_2{4}*threshold))
                cullMAD = cullMAD + 1;
                continue
            end
            if((line_2{3}<min_threshold))
                cullCCC = cullCCC + 1;
                continue
            end
            
            if((line_2{5}<minChan))%JP
                cullChan = cullChan + 1;
                continue
            end
            
            count=count+1;
            match_time_2(count)=datenum([char(line_2{1}) ' ' char(line_2{2})]);
            ccc_2(count)=line_2{3};
            stc_2(count)=double(line_2{5});%JP

        end
        
        
        new_matches=[];
        ids=[];
        %combine the catalogs
        for i=1:1:length(match_time_2)
            if(~sum(find(abs((match_time_2(i)-match_time_1)*86400)<within_seconds)))
%                 new_matches(i,:)=[match_time_2(i), ccc_2(i), template_to_test];
                new_matches(i,:)=[match_time_2(i), ccc_2(i), template_to_test, stc_2(i)];
            else
                first_file_id=find(abs((match_time_2(i)-match_time_1)*86400)<within_seconds);
                if(length(first_file_id)>1)
                    [a,b]=max(ccc_1(first_file_id));
                    first_file_id=first_file_id(b);
                    disp('More than one...')
                end
                ids=[ids;first_file_id];
                switch_on_this=ccc_1(first_file_id)>ccc_2(i);
                switch switch_on_this
                    case 1
%                         new_matches(i,:)=[match_time_1(first_file_id), ccc_1(first_file_id), first_template(first_file_id)];
                        new_matches(i,:)=[match_time_1(first_file_id), ccc_1(first_file_id), first_template, stc_1(first_file_id)];
                   case 0
                        
%                         new_matches(i,:)=[match_time_2(i), ccc_2(i), template_to_test];
                        new_matches(i,:)=[match_time_2(i), ccc_2(i), template_to_test, stc_2(i)];
                end
            end
        end
        possible_ids=1:1:length(match_time_1);
        orig_ids=find(~ismember(possible_ids,ids));
        %new_matches
        tmp=sortrows([new_matches;[match_time_1(orig_ids)', ccc_1(orig_ids)', first_template(orig_ids)', stc_1(orig_ids)']]);
%         tmp=sortrows([new_matches;[match_time_1(orig_ids)', ccc_1(orig_ids)', first_template*ones(length(orig_ids),1), stc_1(orig_ids)']]);
        [vals unique_ids]=unique(tmp(:,1));
        new_matches=tmp(unique_ids,:);
        fid = fopen(file_to_write, 'w');
        fclose(fid);
        
        fid = fopen(file_to_write, 'a');
%         fprintf(fid, '%6.11f %2.2f %3i\n', new_matches'); %
        fprintf(fid, '%6.11f %2.2f %3i %d\n', new_matches'); %
        fclose(fid);
    catch exception
%         rethrow(exception)
    end
end
%}

matches_cell=cellstr(datestr(new_matches(:,1)));
fid = fopen([outdir,'/',region,'_NMFcatalog_HR.txt'], 'w');
fclose(fid);
fid = fopen([outdir,'/',region,'_NMFcatalog_HR.txt'], 'a');
for i=1:1:length(matches_cell)
    fprintf(fid,'%s\t', matches_cell{i}); %
    fprintf(fid,'%2.2f\t%3i %d\n', new_matches(i,2), new_matches(i,3), new_matches(i,4)); %
end
fclose(fid);
disp(['Output File: ',file_to_write])
disp(['Output File: ',outdir,'/',region,'_NMFcatalog_HR.txt'])

end