function runNMF(inputs,params,NMFeventFile,NMFoutFile)

%%%function data_missing=cross_corr(var_name)
% Downloads data from IRIS and, without saving the data to the disk,
% cross-correlates previously identified templates with the data.
%
% Contact Rob Skoumal (skoumarj@miamioh.edu) if you encounter any problems.
%
% MODIFIED BY STEPHEN HOLTKAMP STARTING:OCT-15-2013
%
% =========================================================================
% This program reads from two text files: a "variable" file and a "data"
% file. You can change default values read into this function by editing
% the variable text file [times_name] (default: cross_corr_times.txt).
% You can change the template times by editing the data text file
% [var_name] (default: cross_corr_variables.txt).
%
% This code is intended to be used in a UNIX environment without the use of
% the MATLAB GUI.
%
% =========================================================================
% Input:
%   var_name : name of text file listing the different inputs read into
%              this function. Format described below. If not filename
%              is provided, it will default to cross_corr_variables.txt.
% =========================================================================
% Formatting of var_name file:
%
% #Filename of Template Times *
%   Name of .txt file that contains template start times. In this text file,
%   follow the format: [template #] [year (YYYY)] [day (1-366)] [second]
%   [network] [station] [location] [component], with one template per line.
%
% #Filename of Output File
%   Name of .txt file that will be created to house matches found from the
%   cross correlation procedure. The filename will be appended with
%   '_temp#', where # is the number of the template selected. If this line
%   is left blank, then the name of the inputted template time file will be
%   used (along with the appended '_temp#' notation).
%
% #Template Number(s)
%   The template number(s) from the template times file that are to be
%   correlated. If more than one template is to be used, seperate numbers
%   with a space. If the line is left blank, all templates in the file will
%   be correlated.
%
% #Corr Start *
%   The time that the cross-correlation will start. A year, day of year,
%   and hour must be provided in the format: [year (YYYY)] [day (1-366)]
%   [hour (0-23)].
%
% #Corr End *
%   The last hour that is to be cross-correlated. This means if you wish to
%   cross-correlate only one hour, the #Corr Start and #Corr End will be
%   the same. A year, day of year, and hour must be provided in the format:
%   [year (YYYY)] [day (1-366)] [hour (0-23)].
%
% #Template Length *
%   The length of template that will be created, in seconds.
%
% #Bandpass Filter *
%   The low and high ranges of the bandpass filter, in Hz. Follow the
%   format: [low freq] [high freq].
%
% #MAD Coefficient
%   The coefficient that will be multiplied to the median absolute
%   deviation of the cross-correlation values from the correlation. If a
%   value is not provided by the user, a default MAD coeff of 7 will be
%   used.
%
% #Downsample Rate
%   The rate in samples/sec that the downloaded data will be converted to.
%   If a value is not provided by the user, a default downsample rate of
%   40 samples/sec will be used.
%
% *Indicate required fields that must be provided by user.
% =========================================================================
% Formating of template time file:
%    [temp #] [year] [day] [sec] [network] [station] [location] [component]
%    [temp #] [year] [day] [sec] [network] [station] [location] [component]
%    [temp #] [year] [day] [sec] [network] [station] [location] [component]
%    ...
% =========================================================================
% Sample var_name file:
% #Filename of template start times
% cross_corr_times.txt
%
% #Filename of output file
% output_file.txt
%
% #Template Number(s)
% 1 2
%
% #Corr Start
% 2008 100 0
%
% #Corr End
% 2008 101 23
%
% #Template Length, sec
% 6
%
% #Bandpass Filter, Hz
% 2 10
%
% #MAD Coefficient
% 7
%
% #Downsample Rate
% 40
% =========================================================================
% Sample template time file:
%   1 2008 100 60 PB B039 -- EH1
%   1 2008 100 60 PB B039 -- EH2
%   2 2008 100 605 PB B039 -- EH1
%   2 2008 100 606 PB B039 -- EH2
% =========================================================================
% Needed files:
%  -bandpass.m
%  -datevec2doy.m
%  -download_data.m
%  -IRIS-WS-2.0.2.jar
%  -irisFetch.m
%  -/median/
%    -fast_median.cpp
%    -fast_median_ip.cpp
%    -nth_element.cpp
%    -nth_element_ip.cpp
%    -fast_median.h
%    -nth_element.h
%    -unshare.h
%    -fast_mad.m
%    -fast_median.m
%    -fast_median_ip.m
%    -nth_element.m
%    -nth_element_ip.m
%    -fast_median.mexa64
%    -nth_element.mexa64
% =========================================================================
% Rob Skoumal, skoumarj@miamioh.edu, 9/17/13
% =========================================================================
% clear %JP

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
% Length of download chunk from IRIS, in seconds. Hour = 3600 ; Day = 86400
download_chunk_length = params.downloadChunkLen;
% ds = datasource('winston','130.118.152.130',16022);
ds = inputs.ds;

mkfigs = params.mkfigs;
% f=filterobject('L',[5],3);
vis = params.vis;
debug = params.debug;
qcCCC = params.qcCCC; % only make figs with CCC > than
cccmax = 1.00; %JP: new filter for bad data. good data should never be above 1
stdcut = params.stdcut; %JP: new fitler for bad data. large std means likely bad channel
templSearchWindow = params.templSearchWindow; %JP: only search this many days before and after any given template

%% Assigning default values
% default_var_name='cross_corr_variables_Kasatochi_Eruption_1.txt';
% default_var_name='agung_NMFvars.txt';

default_mad_coeff=7;
default_sample_rate=40;
% database=1;

%if nargin == 0
% var_name=default_var_name;
%end

% if ~isequal(var_name(end-3:end),'.txt')
%     var_name=[var_name '.txt'];
% end

% Lets the program see the functions folder.
% addpath('functions')
% addpath(genpath('~/mbin/HoltkampFunctions'));

%%
if isempty(gcp('nocreate'))
    try
        parpool(8);%desktop
    catch
        parpool(4);%laptop
    end
end
% pctRunOnAll warning('off','signal:findpeaks:largeMinPeakHeight')
pctRunOnAll warning('off','all')

%% Reading Variables File

% Creates the file IDs for the variable file.
% FID_var = fopen(var_name);

% Makes sure the variable text file can be opened.
% if FID_var == -1
%     error(['Unable to open variable file ' var_name])
% end

% Reads variable inputs from txt file
% cross_corr_var = textscan(FID_var, '%s', 29, 'delimiter', '\n');
% cross_corr_var=cross_corr_var{1};
% fclose(FID_var);

% Makes sure the variable txt file follows the strict formatting
% arbitrarily picked by the author.
% if length(cross_corr_var)<29
%     error('Variable file is not the proper length.')
% else
%     details(cross_corr_var)
% end
% empty_check=cellfun(@isempty,cross_corr_var);
% pound_check=strfind(cross_corr_var, '#');
% pound_check=cellfun(@isempty,pound_check);
% if any(~empty_check(3:3:27))
%     error('There is an issue with the formatting (spacing) of the variable text file.')
% elseif any(pound_check(1:3:28))
%     error('There is an issue with the formatting (#s) of the variable text file.')
% end
% clear empty_check

% Reads in the assigned variables from the txt file
template_times_name=NMFeventFile;
times_name_output=NMFoutFile;

%%%Template numbers can be set one of two ways
%First way: Read template numbers from the variables file
% template_numbers=sscanf(cross_corr_var{8},'%s');
% template_numbers=str2num(template_numbers); %JP: allow 1:X format
%Second way: set a range of template numbers here
%  template_numbers=[2];

temp_start_date=params.startDate;%[sscanf(cross_corr_var{11},'%c') ':00:00'];
temp_end_date=params.stopDate;%[sscanf(cross_corr_var{14},'%c') ':00:00'];
template_length=params.templateLen; %str2double(cross_corr_var{17});
bandpass_filter=[params.flo,params.fhi];%sscanf(cross_corr_var{20},'%f %f');
mad_coeff=params.MAD; %str2double(cross_corr_var{23});
new_sample_rate=params.newSampleRate;%str2double(cross_corr_var{26});
baseDir = inputs.outDir;%sscanf(cross_corr_var{29},'%s'); %JP add
outDir = fullfile(baseDir,'NMF');
% template_times_name=fullfile(baseDir,template_times_name);
% times_name_output=fullfile(outDir,times_name_output);

QCdir1 = fullfile(outDir,'DailyFigs');
QCdir2 = fullfile(outDir,'MatchFigs');
[~,~,~] = mkdir(QCdir1);
[~,~,~] = mkdir(QCdir2);

% diaryFileName = fullfile(outDir,['NMF_',datestr(now,30),'_diary.txt']);
% diary(diaryFileName);
%% Interprets Read Variables File

if isempty(template_times_name)
    error('No template time input file was given.')
else
    if ~isequal(template_times_name(end-3:end),'.txt')
        template_times_name=[template_times_name '.txt'];
    end
end

% Error catches for template number
if ~isempty(template_numbers) && ~all(template_numbers>=1)
    error('Template numbers must be an integer greater or equal to 1.')
end

% Error catches for start/end correlation time
%{

%}

% The starting and ending times day are assigned.
start_date=temp_start_date;%datenum([sscanf(cross_corr_var{11},'%c') ':00:00']);
end_date=temp_end_date; %datenum([sscanf(cross_corr_var{14},'%c') ':00:00']);

% Makes sure the start and end date are appropriately assigned.
if start_date > end_date
    error('Start correlation date cannot be later than the end correlation date.')
end

% Error catches for template length
if isempty(template_length)
    error('No template length was provided.')
elseif template_length<0
    error('Template length must be one positive integer.')
elseif isnan(template_length)
    error('Template length must be one positive integer.')
end

% If no bandpass filter specs were given, it will error.
if length(bandpass_filter)~=2
    error('A low and high range for the bandpass filter must be given.')
end

% Assigns a default downsample rate if empty.
if isempty(new_sample_rate)
    display(['No sample rate provided. Using: ' num2str(default_sample_rate)])
    new_sample_rate=default_sample_rate;
end

% Assigns a default MAD Coeff if empty.
if isempty(mad_coeff)
    display(['No MAD coefficient provided. Using: ' num2str(default_mad_coeff)])
    mad_coeff=default_mad_coeff;
end


%% Reading Template Times File

% Creates the file ID for the times text file.
FID_times = fopen(template_times_name);

% Makes sure the time text file can be opened.
if FID_times == -1
    error(['Unable to open time file, ' template_times_name])
end

% Reads times in from txt file
temp_read_in = textscan(FID_times, '%d %s %s %s %s %s %s %s %s'); %JP format
% temp_read_in = textscan(FID_times, '%d %s %s %s %s %s'); %SH format

cross_corr_times=double(cell2mat(temp_read_in(1)));
station=[temp_read_in{4} temp_read_in{5} temp_read_in{6} temp_read_in{7}]';
%datenum([char(temp_read_in{2}(1)) ' ' char(temp_read_in{3}(1))])
%clear temp_read_in
fclose(FID_times);

% Checks to see if the read file is empty
if isempty(cross_corr_times)
    error(['No templates were found in ' template_times_name])
end

% If template_numbers is empty, it does all templates in the file
if isempty(template_numbers)
    template_numbers=1:max(temp_read_in{1});
end

% Finds what line numbers contain the templates selected
line_numbers=cell(1,length(template_numbers));
for i=1:length(template_numbers)
    line_numbers{1,i}=find(cross_corr_times(:,1)==template_numbers(i));
end

% Checks to see if any of the template numbers were not found.
if any(cellfun(@isempty,line_numbers))
    error(['No templates were found for template #(s): ' num2str(template_numbers(cellfun(@isempty,line_numbers))')])
end

% Finds the number of hours that will be correlated over
num_hours=length(start_date:datenum(0,0,0,1,0,0):end_date);

% Lets the function see the files in the normxcorr folder.
% addpath('functions/normxcorr');
% % Lets the function see the files in the median folder.
% addpath('functions/median');


fprintf(', from %s to %s\n', datestr(temp_start_date), datestr(temp_end_date))

% Estimates the run time of the correlations, assuming 1 hour takes XX sec
display(['Estimated run time: ~' num2str(num_hours*sum(cellfun(@length,line_numbers))*1/57) ' sec or ' num2str(num_hours*sum(cellfun(@length,line_numbers))*1/57/86400) ' days.'])
run_time=tic;

%% Correlates templates
% ER=1;
for i=1:length(line_numbers)
    
    display(['   Template ' num2str(template_numbers(i)) '...'])
    good_matches_ct = 0;
    
    % Assigns the output match time file name. Makes sure the name ends in '.txt'.
    if isempty(times_name_output)
        times_name_output2=[template_times_name(1:end-4) '_templ' num2str(template_numbers(i)) '.txt'];
    else
        if isequal(times_name_output(end-3:end),'.txt')
            times_name_output2=[times_name_output(1:end-4) '_templ' num2str(template_numbers(i)) '.txt'];
        else
            times_name_output2=[times_name_output '_templ' num2str(template_numbers(i)) '.txt'];
        end
    end
    
    FID_output=fopen(times_name_output2,'w');
    %fprintf(FID_output,'MADCOEFF %d ; START %c ; END %c ; BANDPASS %d-%d ; DOWNSAMPLE %d ; STATIONS: ', mad_coeff, ...
    %    temp_start_date, temp_end_date, bandpass_filter(1), bandpass_filter(2),new_sample_rate);
    %fprintf(FID_output,'%s %s %s, ',station{1:3,line_numbers{i}(1:end-1)});
    %fprintf(FID_output,'%s %s %s',station{1:3,line_numbers{i}(end:end)});
    
    % Makes the templates
    templates=zeros(length(line_numbers{i}),new_sample_rate*template_length);
    template_time=zeros(length(line_numbers{i}),1);
    
    %     parfor j=[line_numbers{i}']
    parfor j=[line_numbers{i}']
        
        %        line_num=line_numbers{i}(j);
        %         template_year=(cross_corr_times(line_num,2));
        %         template_day=(cross_corr_times(line_num,3));
        %         template_sec=(cross_corr_times(line_num,4));
        
        %         template_time(j,1)=datenum(template_year,0,template_day,0,0,template_sec);
        
        template_time(j,1) = datenum([char(temp_read_in{2}(j)) ' ' char(temp_read_in{3}(j))]);
        scnl=scnlobject(station{2,j},station{3,j},station{1,j},station{4,j});
        try
            template = load_waveformObject_VDAP(ds,scnl,template_time(j,1),template_time(j,1)+template_length/86400,new_sample_rate);
            template = demean(template);
            template = fix_data_length(template,new_sample_rate*template_length); %JP add to fix parfor assignment error
            template=get(template,'DATA');
        catch exception
            %error('No data found for the template')
            disp(['Template ' station{2,j} ' ' station{3,j} ' ' station{1,j} ' on ' datestr(template_time(j,1)) ' did not load'])
            template = [];
        end
        template=bandpass(template,bandpass_filter(1),bandpass_filter(2),1/new_sample_rate,3);
        %template=template(new_sample_rate*2:end-new_sample_rate*2-1);
        %template=align(template,template_time(j,1),new_sample_rate);
        %         size(template);
        try
            templates(j,:)=template;
        catch exception %% JP: remove below sample fix b/c it caused parfor errors, see fix above
            %             try
            %             templates(j,:)=[template;0];
            %             catch exception
            template = [];
            %             end
        end
    end
    
    %% Finds the lag of the different stations
    
    % finds the earliest template time in the list of templates
    min_i=min(find(template_time));
    
    % Finds the lag between the earliest and later template arrivals.
    % Also converts the datenums into their hour/min/sec components.
    [~,~,~,h_temp,m_temp,s_temp]=datevec(template_time-template_time(min_i));
    
    % Converts the lag into number of samples
    lag{i,1}=(s_temp+m_temp*60+h_temp*360)*new_sample_rate;
    
    
    %clear template_time min_i
    
    
    data_length=download_chunk_length*new_sample_rate;
    day_of_time=1/new_sample_rate:1/new_sample_rate:download_chunk_length;
    template_times=1/new_sample_rate:1/new_sample_rate:template_length;
    lineNums = line_numbers{i}';
    
    if debug
        datas=zeros(numel(lineNums),new_sample_rate*download_chunk_length);
    end
    
    %% JP: only search templSearchWindow days before and after a specific
    %template
    tSW1 = floor(template_time(line_numbers{i}(1))+templSearchWindow(1));
    tSW2 = ceil(template_time(line_numbers{i}(1))+templSearchWindow(2));
    if start_date<tSW1
        start_date1=tSW1;
    else
        start_date1=start_date;
    end
    if end_date>tSW2
        end_date1=tSW2;
    else
        end_date1=end_date;
    end
    disp(['   scan from ',datestr(start_date1),' to ',datestr(end_date1)])
    %%
    for time=start_date1:datenum(0,0,0,0,0,download_chunk_length):end_date1
        %     for time = datenum('2014-06-26 22:11:36.630','yyyy-mm-dd HH:MM:SS.FFF')
        display(datestr(time))
        
        % Pre-allocates the space needed for the correlation values.
        corr_sum=zeros(1,download_chunk_length*new_sample_rate);
        corrsmax=zeros(1,numel(lineNums));
        corrs=zeros(numel(lineNums),download_chunk_length*new_sample_rate);
        
        try
            %tic
            %             parfor j=[line_numbers{i}']
            parfor j=1:numel(lineNums)
                
                scnl=scnlobject(station{2,lineNums(j)},station{3,lineNums(j)},station{1,lineNums(j)},station{4,lineNums(j)});
                try
                    data = load_waveformObject_VDAP(ds,scnl,time,time+datenum(0,0,0,0,0,download_chunk_length),new_sample_rate);
                    
                    if ~isempty(data)
                        data = demean(data);
                        data = fix_data_length(data,new_sample_rate*download_chunk_length); %JP add to fix parfor assignment error
                        data=get(data,'DATA');
                        
                        %disp(num2str(length(data)))
                        %download_data(time,download_chunk_length,new_sample_rate,station{1,line_numbers{i}(j)},station{2,line_numbers{i}(j)},station{4,line_numbers{i}(j)},station{3,line_numbers{i}(j)});
                        data(isnan(data))=0;
                        %                     data(find(data>1000000))=1000000;
                        %                     data(find(data<-1000000))=-1000000;
                        %
                        data=bandpass(data,bandpass_filter(1),bandpass_filter(2),1/new_sample_rate,3);
                        %data=align(data,time,new_sample_rate);
                        
                        if debug
                            datas(j,:)=data;
                        end
                        
                    else
                        display(['No data found: ',get(scnl,'station'),' ',get(scnl,'channel')])
                        %                         continue
                    end
                    
                catch exception
                    % If no data is found, it makes a record.
                    error(['No data found: ',get(scnl,'station'),' ',get(scnl,'channel')])
                    %data_missing(ER,1:3)={station{1,line_numbers{i}(j)} , station{2,line_numbers{i}(j)} ,station{3,line_numbers{i}(j)}};
                    %data_missing{ER,4}=time;
                    %                     continue  %%BUG FIND! parfor
                    %                     doesn't like continue statements,
                    %                     remove them
                end
                
                %try
                % Correlates template with data
                if ~isempty(data)
                    try
                        %                     corr_1=normxcorr2_mex(templates(j,:), data'); %JP:
                        %                     sometimes this has fewer false positives than
                        %                     _general
                        
                        corr_1 = normxcorr2_general(templates(lineNums(j),:), data',numel(templates(lineNums(j),:)));%JP: this is a matlab community download
                        
                        % below fix to replace spurious peaks due to change
                        % from missing data to real data again.  Can't figure
                        % out a better way. normxcorr2 still gives bad peaks
                        % sometimes after(before?) data gaps
                        ii = find(corr_1==0);
                        iii = find(diff(ii)~=1);
                        ip = ii(iii)+1;
                        im = ii(iii)-1;
                        corr_1(ip) = 0;
                        corr_1(im) = 0;
                        
                        %                     figure
                        %                     ax1=subplot(3,1,1);
                        %                     plot(data)
                        %                     title('data')
                        %                     ax2=subplot(3,1,2);
                        %                     plot(corr_1o,'r'), hold on
                        %                     plot(corr_1,'b');
                        %                     plot(ii,corr_1(ii),'k.')
                        %                     plot(ii(iii),corr_1(ii(iii)),'bo')
                        %                     plot(ip,corr_1(ip),'mo')
                        %                     plot(im,corr_1(im),'co')
                        %                     title('normxcorr2_general','interpreter','none')
                        %                     ax3=subplot(3,1,3);
                        %                     plot(corr_1b)
                        %                     title('normxcorr2_mex','interpreter','none')
                        %                     linkaxes([ax1 ax2 ax3],'x')
                        %                     zoom('xon')
                        
                    catch exception
                        disp('normxcorr2 DID NOT WORK')
                        corr_1=zeros(1,download_chunk_length*new_sample_rate);
                    end
                    % Adds the correlation values to the corr_sum, taking station
                    % lag into consideration.
                    corrs(j,:)=[corr_1(new_sample_rate*template_length+lag{i}(lineNums(j)):end) zeros(1,lag{i}(lineNums(j))) zeros(data_length-length([corr_1(new_sample_rate*template_length+lag{i}(lineNums(j)):end) zeros(1,lag{i}(lineNums(j)))]),1)];
 
                    %length([corr_1(new_sample_rate*template_length+lag{i}(j):end) zeros(1,lag{i}(j))])
                    try
                        add_on=[corr_1(new_sample_rate*template_length+lag{i}(lineNums(j)):end) zeros(1,lag{i}(lineNums(j))) zeros(data_length-length([corr_1(new_sample_rate*template_length+lag{i}(lineNums(j)):end) zeros(1,lag{i}(lineNums(j)))]),1)];
                        corrsmax(j) = max(corr_1);
                        
                        if length(add_on)==data_length && corrsmax(j) <= cccmax %JP: corrsmax attempt to remove bad data channels
                            corr_sum=corr_sum+add_on;
                        else
                            disp(['Removed ',get(scnl,'station'),' ',get(scnl,'channel')])
                            % this removes whole days of data, but there is
                            % prob a better way to deal with the bad data w/i the day only
                        end
                    catch exception
                        %disp(['corr_sum DID NOT WORK' station{2,j} station{3,j} station{1,j}])
                        %disp(['Data length is: ' num2str(length(data))])
                        disp(['add on is :' num2str(length([corr_1(new_sample_rate*template_length+lag{i}(j):end) zeros(1,lag{i}(j)) zeros(data_length-length([corr_1(new_sample_rate*template_length+lag{i}(j):end) zeros(1,lag{i}(j))]),1)]))])
                        disp(['corr_1 is :' num2str(length(corr_1))])
                    end
                    %                      disp(['add on is :' num2str(length([corr_1(new_sample_rate*template_length+lag{i}(j):end) zeros(1,lag{i}(j)) zeros(data_length-length([corr_1(new_sample_rate*template_length+lag{i}(j):end) zeros(1,lag{i}(j))]),1)]))])
                    %                     disp(['corr_1 is :' num2str(length(corr_1))])
                    %                     disp(num2str(length(corr_sum)))
                    %disp(num2str(max(corr_sum))
                    %catch exception
                    %try
                    %corr_sum=corr_sum+[corr_1(new_sample_rate*template_length+lag{i}(j):end) zeros(1,lag{i}(j)) 0];
                    %disp(num2str(max(corr_sum))
                    %catch exception
                    %end
                    %end
                end
                
            end
            %toc
        catch exception
            disp('ALL DID NOT WORK')
        end
        %corr_sum=sum(corr_sum);
        % if all corr values are 0, go to next hour.
        if nnz(corr_sum)==0
            continue
        end
        % Calculates the median absolute deviation of the correlation coeff,
        % then multiplies the value by the threshold set by the user.
        min_ccc=std(corr_sum(corr_sum~=0)/1.4826,0); % changed from Steven's code
        min_peak_height=max(min_ccc*mad_coeff,1);
        % Finds all matches above the threshold
        [good_match_values,good_matches]=findpeaks(corr_sum,'MINPEAKHEIGHT',min_peak_height,'MINPEAKDISTANCE',5*new_sample_rate,'MinPeakWidth',2); %5 or .5???
        
        % JP: find matches with std of channel corrs < .25
        maxcorrs = zeros(numel(lineNums),numel(good_matches));
        for s=1:numel(good_matches)
            maxcorrs(:,s) = max(corrs(:,good_matches(s):good_matches(s)+template_length*new_sample_rate),[],2);
        end
%         maxcorrs(maxcorrs==0)=nan;
        maxcorrs(maxcorrs<0.0001)=nan;
        stdmc = std(maxcorrs,'omitnan');
        istds = stdmc < stdcut;
        if sum(istds) > 0
            disp(['  ',int2str(length(istds)),'  Matches Found'])
        end
        if sum(~istds) > 0
            disp(['  ',int2str(sum(~istds)),' Matches removed by std threshold (',num2str(stdcut),')'])
            disp(['  ',num2str(stdmc)])
        end
        
        good_matches = good_matches(istds);
        good_match_values = good_match_values(istds);
        maxcorrs = maxcorrs(:,istds);

        % JP: add factor for station count used
        stc = sum(corrsmax > 0 & corrsmax <= 1);
 
        % JP: plot nstations per sample?
%         iscps = corrs~=0;
%         stationCtPerSample = sum(iscps);
        
        if mkfigs %&& ~isempty(good_matches) %JP
            % JP: here is where to make daily detection figure
            figure('visible',vis)
            plot(corr_sum); hold on
            plot(size(corr_sum),[min_peak_height min_peak_height])
            plot(good_matches,good_match_values,'ro')
%             plot(1:length(corr_sum),stationCtPerSample,'g-')
            title(datestr(time))
            xlabel('sample #')
            ylabel('correlation value')
            %             xlim([1.72755e6  1.72765e6])
            %             axis([size(corr_sum) -3 max(corr_sum)])
            xlim(size(corr_sum)+[-1 1])
            ylim([-3.1 7.1])
            zoom('xon')
            print([QCdir1,filesep,datestr(time,'yyyymmdd'),'_templ_',num2str(template_numbers(i))],'-dpng')
            
        end
        
        if ~isempty(good_matches) %&& std(corrsmax) < 0.25  %JP: corrsmax, another attempt to remove bad data matches
            good_matches_value=corr_sum(good_matches)';
            
            good_matches=good_matches/new_sample_rate;
            good_matches=time+datenum(0,0,0,0,0,good_matches);
            to_output=good_matches;
            [temp_time(:,1),temp_time(:,2),temp_time(:,3),temp_time(:,4),temp_time(:,5),temp_time(:,6)]=datevec(good_matches);
            day_out(:,1)=datevec2doy(temp_time');
            year_out(:,1)=temp_time(:,1);
            sec_out(:,1)=temp_time(:,4)*60*60+temp_time(:,5)*60+temp_time(:,6);
            clear temp_time
            
            % Prepares output data, then writes it to a text file.
            output_data=[good_matches_value,min_ccc*ones(length(good_matches_value),1),stc*ones(length(good_matches_value),1),stdmc(istds)'];
            clear day_out year_out sec_out
            
            for each_match=1:1:length(to_output)
                
                good_matches_ct = good_matches_ct + 1;
                
                disp([sprintf('%s',datestr(to_output(each_match),'dd-mmm-yyyy HH:MM:SS ')) sprintf('%.4f %.3f %d %.2f',output_data(each_match,:)')])
                
                fprintf(FID_output,'%s',datestr(to_output(each_match),'dd-mmm-yyyy HH:MM:SS '));
                fprintf(FID_output,'%.4f %.3f %d %.2f\n',output_data(each_match,:)');
                
                if mkfigs && good_matches_value(each_match) >= qcCCC
                    ln = line_numbers{1,i}(1);
                    template_time2 = datenum([char(temp_read_in{2}(ln)) ' ' char(temp_read_in{3}(ln))]);
                    
                    %make QC fig here
                    clear w wt
                    
                    datas3 = zeros(numel(lineNums),template_length*new_sample_rate);  %[];
                    datas4 = zeros(numel(lineNums),template_length*new_sample_rate); %[];
                    ct = 0;
                    for jj =  lineNums
                        scnl=scnlobject(station{2,(jj)},station{3,(jj)},station{1,(jj)},station{4,(jj)});
                        ct = ct + 1;
                        try
                            w(ct) = load_waveformObject_VDAP(ds,scnl,to_output(each_match),to_output(each_match)+datenum(0,0,0,0,0,template_length),new_sample_rate);
                            w(ct) = demean(w(ct));
                            sampleRate=get(w(ct),'freq');
                            w(ct) = fix_data_length(w(ct),template_length*sampleRate); %JP add to fix parfor assignment error
                            %                             w(ct) = filtfilt(f,w(ct));
                        catch
                            disp(['cannot load ',get(scnl,'station'),' ',get(scnl,'channel')])
                        end
                        try
                            wt(ct)= load_waveformObject_VDAP(ds,scnl,template_time2,template_time2+datenum(0,0,0,0,0,template_length),new_sample_rate);
                            wt(ct) = demean(wt(ct));
                            wt(ct) = fix_data_length(wt(ct),template_length*sampleRate); %JP add to fix parfor assignment error
                            %                             wt(ct) = filtfilt(f,wt(ct));
                        catch
                            disp(['cannot load ',get(scnl,'station'),' ',get(scnl,'channel')])
                        end
                    end
                    
                    try %JP
                        figure('visible',vis), hold on
                        count = 1;
                        [max_value,max_ind]=max(corr_sum);
                        
                        for jj = lineNums
                            wd = get(w(count),'DATA');
                            wstr = [get(w(count),'station'),', ',get(w(count),'channel')];
                            datas3(count,1:template_length*new_sample_rate) = bandpass(wd,bandpass_filter(1),bandpass_filter(2),1/new_sample_rate,3);
                            %                             datas3(count,1:template_length*new_sample_rate) = wd;
                            
                            wdt= get(wt(count),'DATA');
                            wstr2 = [get(wt(count),'station'),', ',get(wt(count),'channel')];
                            datas4(count,1:template_length*new_sample_rate) = bandpass(wdt,bandpass_filter(1),bandpass_filter(2),1/new_sample_rate,3);
                            %                             datas4(count,1:template_length*new_sample_rate) = wdt;
                            
                            if sum(~strcmp(wstr,wstr2)) ~= 0
                                disp('channel and/or station does not match')
                            end
                            plot(1:length(datas4(count,:)),datas4(count,:)./max(datas4(count,:))+count*2,'b')
                            plot(1:length(datas3(count,:)),datas3(count,:)./max(datas3(count,:))+count*2,'r')
                            text(length(datas4(count,:))-20,count*2,wstr,'color','k','BackgroundColor','w','interpreter','none','fontsize',9)
                            text(0,count*2,num2str(maxcorrs(count,each_match),'%.2f'),'BackgroundColor','w'); % currently showing max for day, not match. Should update
                            %                             if debug
                            %                                 plot(1:length(wd),wd./max(wd)+count*2+2*length(lns),'r')
                            %                                 text(length(wd)-20,count*2+2*length(lns),wstr,'color','k','BackgroundColor','w','interpreter','none')
                            %                             end
                            count = count+1;
                        end
                        text(length(datas4(count-1,:))-120,1,['std = ',num2str(std(maxcorrs(:,each_match),'omitnan'),'%3.2f')]) %std of day maxes, not match.  Should update
                        %                         title(['Template ',int2str(template_numbers(i)),' @ ',datestr(template_time2),', Match ',int2str(good_matches_ct),' @ ',datestr(to_output(each_match)),', CCC: ',num2str(output_data(each_match,1),'%3.1f')],'interpreter','none')
                        title(['{\color{blue}Template ',int2str(template_numbers(i)),'@',datestr(template_time2,'mm/dd/yyyy HH:MM:SS'),',} {\color{red}Match ',int2str(good_matches_ct),'@',datestr(to_output(each_match),'mm/dd/yyyy HH:MM:SS'),'}, CCC: ',num2str(output_data(each_match,1),'%3.1f')])
                        %         xlim([-t_pre t_post])
                        xlabel('sample since OT')
                        set(gca,'YTickLabel',[])
                        set(gca,'YTick',[])
                        print([QCdir2,filesep,datestr(to_output(each_match),30),'_T',int2str(template_numbers(i)),'_M',int2str(good_matches_ct),'_CC',num2str(output_data(each_match,1),'%3.1f'),'.png'],'-dpng')
%                         print([QCdir2,filesep,'Templ',int2str(template_numbers(i)),'_match',int2str(good_matches_ct),'_CCC_',num2str(output_data(each_match,1),'%3.1f'),'.png'],'-dpng')
                        %                     close
                    catch
                        warning('Not able to make figure')
                    end
                end
            end
            clear output_data good_matches
        end
        if debug %JP: added QC fig from SH original separate script
            figure
            count=1;
            dot = length(day_of_time)/1; %shorten for smaller size plot
            ax1= subplot(2,1,1);
            for j=[line_numbers{i}']
                plot(day_of_time(1:dot),datas(j,1:dot)./max(datas(j,1:dot))+count*2,'b')
                hold on
                [max_value,max_ind]=max(corr_sum(1:dot));
                plot(template_times+max_ind/new_sample_rate+(lag{i}(j)-1)./new_sample_rate,templates(j,:)./max(templates(j,:))+count*2,'r')
                text(0,count*2+.3,num2str(corrs(j,max_ind),'%.2f'))
                count=count+1;
            end
            axis tight
            title(['Template ' num2str(template_numbers(i))])
            ax2=subplot(4,1,3);
            count=1;
            disp(['Template ' num2str(template_numbers(i))])
            for j=[line_numbers{i}']
                disp(['Trace ' num2str(count) ': ' num2str(any(corrs(j,:)))])
                plot(day_of_time(1:dot),corrs(j,1:dot)+count*1,'b')
                hold on
                [max_value,max_ind]=max(corr_sum(1:dot));
                text(0,count*1+.3,num2str(corrs(j,max_ind),'%.2f'))
                count=count+1;
            end
            axis tight
            ax3=subplot(4,1,4);
            plot(day_of_time(1:dot),corr_sum(1:dot),'b')
            hold on
            axis tight
            ylim([0 9])
            plot([day_of_time(1) day_of_time(end)],[0.948 0.948],'r')
            title(max(corr_sum))
            linkaxes([ax1 ax2 ax3],'x')
            zoom('xon')
        end
        if mkfigs
            close all
        end
    end
    fclose(FID_output);
end

display(['Run time: ' num2str(toc(run_time),'%.0f') ' sec. ' num2str(num_hours*sum(cellfun(@length,line_numbers))/floor(toc(run_time)),'%.3f') ' hrs correlated/sec'])
display('Correlation finished.')
% diary OFF
