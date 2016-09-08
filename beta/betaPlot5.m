function p = betaPlot5(volcname, beta_output, eruption_windows, bad_data_days, params)
disp(mfilename('fullpath'))
%% UPDATES
%{
ver4
2015 Nov 04 - Change output to plot handle.
2015 Nov 04 - Remove figure creation (i.e., >> fh = figure;). If you make a
figure in this file, whenever you run this script, it will always create a
fiugre, even if the output is only a plot handle. I bet like this, the plot
handle doesn't even have to be given.
2015 Nov 04 - Add comments.

ver5
2015 Nov 06 - Adds legend to plot
2015 Nov 06 - Adds documentation
2015 Dec 07 - Changes bad data plot from squares to rectangles
2015 Dec 08 - Fixes issues with rectangles (when there are no bad data)
%}

%% ERROR HANDLING for known issues

% The limitation here is based on the color scheme.
% Automatic picking of the next color would fix this.
if (numel(beta_output(1).bin_sizes) > 3)
    error('This version only supports three short term window values for beta.')
end


%%

p = []; % initialize output
legend_items = []; % initialize legend items;
legend_text = '';

%% basic data gathering

max_bc_val = max(extractfield(beta_output,'bc')); if isnan(max_bc_val); max_bc_val =  0; end
min_bc_val = min(extractfield(beta_output,'bc')); if isnan(min_bc_val); min_bc_val = -1; end


%% Plot Moving Window Beta

clr = ['g', 'b', 'r']; % pre-define 3 color options
color(1,:) = [0.38 0.85 0.38]; % darker than 'g'
color(2,:) = [ 0 0 1 ]; % 'b'
color(3,:) = [1 0 0 ]; % 'r'

%save gmt data file
clear gmtDataFile
ct = 1;
        
n_beta_legends = 0; % stores the number of legends created for beta thresholds
for n = 1:length(beta_output) % for each background period
    
    if ~isempty(beta_output(n).bc) % only start plotting routine if there are data
        
        start = beta_output(n).start; % start of the background window
        stop = beta_output(n).stop; % stop of the background window
        bc = beta_output(n).bc; % beta values for each window
        Be = beta_output(n).Be; % empirical beta value for entire window
        t_checks = beta_output(n).t_checks; % begining date of each test window corresponding to bc
        start_dt = datetime(datestr(start)); stop_dt = datetime(datestr(stop)); % start and stop of background windows in 'datetime' var type
        start_dt = start; stop_dt = stop; % start and stop of background windows in 'datetime' var type
                

        
        for i = 1:size(bc,2) % for each window size
            
            % draw plots for beta data
            [x, y] = makeStairs(t_checks(:,i), bc(:,i)); % turns beta values from a 'plot' to 'stairs' in a manner that plays nice wtih 'datetime' variable type
            beta_val = plot(x, y, 'Color', color(i,:), 'LineWidth',2); % draw beta values as a new line
            hold on;
            emp_beta = plot([start stop], [Be(i) Be(i)], 'Color', color(i,:), 'LineStyle', '--', 'LineWidth', 2); % plot theoretical beta value across whole background window
            theo_beta = plot([start stop], [2.57 2.57],'k--','LineWidth',2); % plot theoretical beta threshold
            %
%             p = [p; beta_val; emp_beta]; % append lines to output
            
            %                 % create legend information for the beta values based on
            %                 % the data plotted for the first background time period
            %                 % there should only be 3 pieces of legend information
            %                 % (corresponding to each beta window), so once the script
            %                 % has done this three times, stop
            %             if n_beta_legends < length(beta_output(n).bin_sizes) % if the number of beta legends is still less than the total number of beta tests
            %                 legend_items = [legend_items beta_val emp_beta]; % append the plot handles to legend information
            %                 legend_text = [legend_text, ...
            %                     {[num2str(beta_output(n).bin_sizes(i)) ' day window'], [num2str(beta_output(n).bin_sizes(i)) ' day window empirical thresh.']}];
            %                 n_beta_legends = n_beta_legends + 1; % append legend text descriptions
            %             end;
            
            gmtDataFile(ct,1) = {'>'};
            gmtDataFile(ct,2) = {'-W1,0/0/255'};
            I=find(~isnan(x) & ~isnan(y));
            for ii=I
                ct = ct + 1;
                gmtDataFile(ct,1) = {datestr(x(ii),'yyyy-mm-ddTHH:MM:SS')};
                gmtDataFile(ct,2) = {y(ii)};
            end
            
        end

    end
    
end
% add horizontal threshold line
ct=ct+1;
gmtDataFile(ct,1) = {'>'};
gmtDataFile(ct,2) = {'-W1,0/0/255,--'};
ct=ct+1;
gmtDataFile(ct,1) = {datestr(beta_output(1).start,'yyyy-mm-ddTHH:MM:SS')};
gmtDataFile(ct,2) = {Be(i)};
ct=ct+1;
gmtDataFile(ct,1) = {datestr(beta_output(end).stop,'yyyy-mm-ddTHH:MM:SS')};
gmtDataFile(ct,2) = {Be(i)};
% add horiz theo thres line
ct=ct+1;
gmtDataFile(ct,1) = {'>'};
gmtDataFile(ct,2) = {'-W1,0,--'};
ct=ct+1;
gmtDataFile(ct,1) = {datestr(beta_output(1).start,'yyyy-mm-ddTHH:MM:SS')};
gmtDataFile(ct,2) = {2.57};
ct=ct+1;
gmtDataFile(ct,1) = {datestr(beta_output(end).stop,'yyyy-mm-ddTHH:MM:SS')};
gmtDataFile(ct,2) = {2.57};

%% Plot Bad Data Days - as rectangles

if ~isempty(bad_data_days)
    
    starts_stops = series2period( [], bad_data_days, 1, 'include'); % start/stop pairs of bad data times as n-by-2 vector
    starts = starts_stops(:,1); % start times of bad data periods
    durations = starts_stops(:,2) - starts; % durations of bad data periods
    

        for n = 1:length(starts)
            bad_data_plot = rectangle('Position',[starts(n) min_bc_val durations(n) max_bc_val+1], 'FaceColor', [0.5 0.5 0.5]);
            ct=ct+1;
            gmtDataFile(ct,1) = {'>'};
            gmtDataFile(ct,2) = {'-W1,100 -G100'};
            ct=ct+1;
            gmtDataFile(ct,1) = {datestr(starts(n),'yyyy-mm-ddTHH:MM:SS')};
            gmtDataFile(ct,2) = {min_bc_val};
            ct=ct+1;
            gmtDataFile(ct,1) = {datestr(starts(n)+durations(n),'yyyy-mm-ddTHH:MM:SS')};
            gmtDataFile(ct,2) = {min_bc_val};
            ct=ct+1;
            gmtDataFile(ct,1) = {datestr(starts(n)+durations(n),'yyyy-mm-ddTHH:MM:SS')};
            gmtDataFile(ct,2) = {max_bc_val+1};
            ct=ct+1;
            gmtDataFile(ct,1) = {datestr(starts(n),'yyyy-mm-ddTHH:MM:SS')};
            gmtDataFile(ct,2) = {max_bc_val+1};      
            ct=ct+1;
            gmtDataFile(ct,1) = {datestr(starts(n),'yyyy-mm-ddTHH:MM:SS')};
            gmtDataFile(ct,2) = {min_bc_val};            
        end

    datetick('keeplimits') %JP
    
end

%% Plot eruption windows

max_be_val = max(Be);  % redo this to max Be for better y limits on end plot (JP)
for n = 1:size(eruption_windows,1)
    
        % add rectangle for eruption window
    duration = eruption_windows(n,2) - eruption_windows(n,1);
    eruption = rectangle('Position',[eruption_windows(n,1) min_bc_val duration max_bc_val+1],'FaceColor','r'); hold on;
    
    ct=ct+1;
    gmtDataFile(ct,1) = {'>'};
    gmtDataFile(ct,2) = {['-W1,255/0/0 -G255/0/0']};
    ct=ct+1;
    gmtDataFile(ct,1) = {datestr(eruption_windows(n,1),'yyyy-mm-ddTHH:MM:SS')};
    gmtDataFile(ct,2) = {min_bc_val};
    ct=ct+1;
    gmtDataFile(ct,1) = {datestr(eruption_windows(n,1)+duration,'yyyy-mm-ddTHH:MM:SS')};
    gmtDataFile(ct,2) = {min_bc_val};
    ct=ct+1;
    gmtDataFile(ct,1) = {datestr(eruption_windows(n,1)+duration,'yyyy-mm-ddTHH:MM:SS')};
    gmtDataFile(ct,2) = {max_bc_val+1};
    ct=ct+1;
    gmtDataFile(ct,1) = {datestr(eruption_windows(n,1),'yyyy-mm-ddTHH:MM:SS')};
    gmtDataFile(ct,2) = {max_bc_val+1};
    ct=ct+1;
    gmtDataFile(ct,1) = {datestr(eruption_windows(n,1),'yyyy-mm-ddTHH:MM:SS')};
    
        % add line x-months before eruption (this corresponds to amount of
        % time shown on the map)
    map_start = eruption_windows(n,1)-params.AnomSearchWindow; % 4 months is the amount of time chosen right now
    map_start_line = plot([map_start map_start],[min_bc_val max_bc_val+1], 'LineStyle',':', 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);
    ct=ct+1;
    gmtDataFile(ct,1) = {'>'};
    gmtDataFile(ct,2) = {'-W1,100,-.-.'};
    ct=ct+1;
    gmtDataFile(ct,1) = {datestr(map_start,'yyyy-mm-ddTHH:MM:SS')};
    gmtDataFile(ct,2) = {min_bc_val};
    ct=ct+1;
    gmtDataFile(ct,1) = {datestr(map_start,'yyyy-mm-ddTHH:MM:SS')};
    gmtDataFile(ct,2) = {max_bc_val+1};    
end

% p = [p; erupt_start];

% legend_items = [legend_items; erupt_start(1)];
% legend_text = [legend_text; 'Eruption'];


%
% legend_items = [legend_items erupt_start(1) erupt_end(1) theo_beta bad_data]; % append plot handles to legend information
% legend_text = [legend_text {'Start of Eruptive Period', 'End of Eruptive Period', 'Theoretical Beta thresh. (2.57)', 'No reliable network'}]; % append legend text decriptions
%
% title(volcname)
ylabel('Beta','FontWeight','bold','FontSize',12)
xlabel('Date','FontWeight','bold','FontSize',12)
ylim([min_bc_val max_bc_val])
zoom xon

s6_cellwrite([params.outDir,filesep,volcname,filesep,'gmtData.xy'],gmtDataFile,' ')
%% Plot Bad Data Days - as points
% 
% NOTE: In order to run this section, bad_data_days must be set to NaN if
% it is otherwise empty. I.e., you need this line of code:
% if isempty(bad_data_days), bad_data_days = nan; end;
% bad_data_plot = plot(bad_data_days, max_bc_val, 'sk');
% datetick('keeplimits') %JP
% 
% % p = [p; bad_data_plot];

%% Set order of plot objects

% uistack(eruption,'bottom');
% uistack(bad_data_plot,'bottom');


%% Create Legend

% legend(legend_items, legend_text)

end