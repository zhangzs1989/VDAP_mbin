%% dataseries_pd_plot1
%{
* Plots proximal seismicity vs. distal seismicity. In general, just
compares two different annuli.

* Extended off of seismicTSpd_plot1
1. variable names changed to match new naming convention
    srad -> annulus
    DATA.N, DATA.T, DATA.be -> BETA.*
    ndays -> t_window(*,2)
2. plotted the ERUPTION bars on the bottom
3. increased width of stair step lines
4. Title is now drawn to an explicitly defined axis
5. Normalized figure window position

%}

%% PLOT ROUTINE

volcano_names = unique(LOG.volcano_name);

for v = 1:numel(volcano_names)
    
    LOG2 = LOG(strcmpi(LOG.volcano_name, volcano_names{v}), :);
    LOG3 = LOG2; LOG3.DATA = []; LOG3.BETA = []; LOG3.annulus = [];
    [~, ~, idx] = unique(LOG3);
    options = unique(idx);
    
    for n = 1:numel(options)
        
        LOG4 = LOG2(idx==options(n), :);
        LOG4 = sortrows(LOG4, 'annulus', 'descend');
        Astart = LOG4.catalog_background_time(1,1);
        Astop = LOG4.catalog_background_time(1,2);
        
        f = figure;
        f.Units = 'normalized';
        f.Position = [0.0367 -0.1413 1.3703 0.6625];
        
        ax(1) = subplot(1,4,1:3);
        plot(LOG4.DATA(1).E);
        
        for i = 1:height(LOG4)
            
            if sum(LOG4.annulus(i,:) - [0 2]) == 0 % equivalence statement
                ax(1) = subplot(1,4,1:3);
                tc = LOG4.DATA(i).tc;
                counts = LOG4.DATA(i).binCounts;
                be = LOG4.BETA(i).be;
                be_c = beta2counts(be, LOG4.BETA(i).N, LOG4.t_window(i,2), LOG4.BETA(i).T);
                
                p(1) = stairs(tc, counts, 'b', 'LineWidth', 2);
                hold on;
                p(2) = plot([Astart Astop], [be_c be_c], ...
                'b--');
                
                % map
                axm = subplot(1,4,4);
                plot(LOG4.DATA(i).CAT.Longitude, LOG4.DATA(i).CAT.Latitude, 'ob');
                hold on
                
            elseif sum(LOG4.annulus(i,:) - [2 30]) == 0 % equivalence statement
                ax(1) = subplot(1,4,1:3);
                tc = LOG4.DATA(i).tc;
                counts = LOG4.DATA(i).binCounts;
                be = LOG4.BETA(i).be;
                be_c = beta2counts(be, LOG4.BETA(i).N, LOG4.t_window(i,2), LOG4.BETA(i).T);
                
                p(3) = stairs(tc, counts, 'k', 'LineWidth', 2);
                hold on;
                p(4) = plot([Astart Astop], [be_c be_c], ...
                'k--');
                
                % map
                axm = subplot(1,4,4);
                plot(LOG4.DATA(i).CAT.Longitude, LOG4.DATA(i).CAT.Latitude, 'ok');
                hold on
            end     
            
        end
        
        legend(p([1 3]), 'Proximal Seismicity', 'Distal Seismicity')
        
%         xlim([Astart Astop]);
        ylabel('EQ Counts');
        
        title(ax(1), [LOG4.volcano_name{1} ' | ' ...
            'Max Depth: ' num2str(LOG4.maxdepth(1)) ' km | ' ...
            'Min Mag: ' num2str(LOG4.minmag(1)) ' | ', ...
            'Beta (' num2str(LOG4.t_window(1,2)) ' day window)'])
         
    end
    
end
