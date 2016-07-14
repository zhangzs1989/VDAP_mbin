function [baddata] = getVolcanoNetworkDownDays(volcname, windows, params, inputFiles)

% takes in station stat files and determines station and network down days
% see AKnetworkBadgerJP2.m which runs on UAF badger continuous data

% station data files are 4 columns of [day, dfrac, range, std]
% where day=matlab day, dfrac is fraction of day with data, range of data,
% and standard deviation of data

% minsta = 4; % min number of stations to consider network on
% dfracThres = 0.75; % fraction of day containing data to consider station on
% ddir = '/Users/jpesicek/Dropbox/Research/Alaska/AKDVTs/StaMatFiles/';

dfracThres = params.dfracThres;
minsta = params.minsta;
ddir = inputFiles.StaDataDir;

% this file is still loaded here to check that we are using the
% same number of stations as HB used.
% Could cut out this file and just loop over existing StaDataFiles
% load('/Volumes/EFIS_seis/share/GOLD_STAR_FOR_HELENA/MONITOREDVOLCANO.mat');
%         load('/Volumes/EFIS_seis/share/GOLD_STAR_FOR_HELENA/AVO_VOLCANO_update.mat');
load(inputFiles.HB)

vnames = extractfield(VOLCANO,'name'); % extract names from Helena's object

% get volc coords
for i=1:size(vnames,2)
    TF = strcmp(volcname,vnames(i));
    if TF
        break
    end
end
if ~TF
    
    sprintf('NOTE: ''%s'' not found in Helena''s database. Script will proceed with no bad data days.',volcname);
    baddata = [];
    
else
    
    VOLCANO1 = VOLCANO(i); VOLCANO1.name;
    clear VOLCANO
    
    %pull in station mat files
    for j=1:numel(VOLCANO1.staname)
        
        %check for existing station file
        fname = [ddir,filesep,char(VOLCANO1.staname(j)),'3.mat'];
        if exist(fname,'file')
            load(fname)
            days = STATION(:,1);
            
            II(:,j) = STATION(:,2) < dfracThres; % | (order(STATION(:,3)) - order(STATION(:,4)) < 2);
                                                 % this above criterion makes a big difference in results       
                                                 % it was inherited from
                                                 % Helena, not sure about
                                                 % it...
        % "range in the timeseries be at least 2 orders of magnitude greater than
        % the standard deviation of the time series. " HB

        else
            disp(['Cannot load file: ',fname])
            warning(['Cannot load file: ',fname])
        end
        
    end
    % are there at least minsta stations operating on each day?
    nstasPerDay = sum(~II,2);
    
    ib = nstasPerDay < minsta;
    baddata1 = sort(STATION(ib,1));
    
    ib2 = baddata1 > min(min(windows)) & baddata1 < max(max(windows)); % index of days when the network is down within time period of interest
    
    baddata = baddata1(ib2);
    
    % QC fig
    figure('visible','off'), hold on
%     figure, hold on
    lh = {};
    for d = 1:numel(VOLCANO1.staname)
        
        plot(datetime(datevec(days)),~II(:,d)*d,'.')
        text(days(1),d+.1,[char(VOLCANO1.staname(d)),' ON'])
        lhv = [char(VOLCANO1.staname(d)),' ON'];
        lh = [lh,lhv];
        
    end
    ylim([0.5 numel(VOLCANO1.staname)+1.5])
    plot(datetime(datevec(days)),ib*(d+1),'.')
    lh = [lh,'Network OFF'];
    text(days(1),d+1.1,'Network OFF')
    xlabel('Date')
    title({[VOLCANO1.name,' Seismic Network Status'],['(Day Fraction: ',num2str(dfracThres),', Min #stations: ',int2str(minsta),')']})
%     legend(lh,'location','BestOutside')
    print([params.outDir,filesep,VOLCANO1.name,filesep,VOLCANO1.name,'_NetworkStatus'],'-dpng')
    
    
end


end
