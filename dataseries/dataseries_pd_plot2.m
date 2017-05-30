%% dataseries_pd_plot2
%{
* Plots proximal seismicity vs. distal seismicity. In general, just
compares two different annuli.

* Extended off of dataseries_pd_plot1
1. Only shows distal seismicity
2. Implements TIMEMAP
3. Implements TIMEMAPOVERLAY (first time I've ever done this)
4. Implements TIMEMAPUNDERLAY (first tiem I've ever done this)
5. gets volcano info to use with #3 and #4

%}

%% PLOT ROUTINE

volcano_names = unique(LOG.volcano_name);

for v = 1:numel(volcano_names)
    
    vinfo = volcanoes(strcmpi(volcanoes.name, volcano_names{v}), :);
    
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
%                 
%                 p(1) = stairs(tc, counts, 'b', 'LineWidth', 2);
%                 hold on;
%                 p(2) = plot([Astart Astop], [be_c be_c], ...
%                 'b--');
%                 
%                 % map
%                 axm = subplot(1,4,4);
%                 plot(LOG4.DATA(i).CAT.Longitude, LOG4.DATA(i).CAT.Latitude, 'ob');
%                 hold on
                
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
                axmb(1) = timemap(datetime2(LOG4.DATA(i).CAT.DateTime), ...
                    LOG4.DATA(i).CAT.Latitude, LOG4.DATA(i).CAT.Longitude, 'ok');
                [latann1, lonann1] = reckon(vinfo.lat(1), vinfo.lon(1), km2deg(2), 0:360);
                [latann2, lonann2] = reckon(vinfo.lat(1), vinfo.lon(1), km2deg(30), 0:360);
                axmb(2) = timemapoverlay(axm, vinfo.lat(1), vinfo.lon(1), '^r', 'MarkerFaceColor', 'r');
                hold on
                axmb(3) = timemapoverlay(axm, latann1, lonann1, 'r', 'LineWidth', 2);
                axmb(4) = timemapoverlay(axm, latann2, lonann2, 'r', 'LineWidth', 2);
                axmb(5) = timemapunderlay(axm, LOG4.DATA(i).CAT.Latitude, LOG4.DATA(i).CAT.Longitude, ...
                    'o', 'Color', [0.67 0.67 0.67]);
                axm.Color = 'none'; for n = 1:numel(axmb)-1, axmb(n).Color = 'none'; end
                for n = 1:numel(axmb), axmb(n).ZLim = [min(latann2) max(latann2)]; axmb(n).YLim = [min(lonann2) max(lonann2)]; end
                linkaxes([ax(1) axm], 'x')
                
            end
            
        end
        

        
%         legend(p([1 3]), 'Proximal Seismicity', 'Distal Seismicity')
        
%         xlim([Astart Astop]);
        ylabel('EQ Counts');
        
        title(ax(1), [LOG4.volcano_name{1} ' | ' ...
            'Max Depth: ' num2str(LOG4.maxdepth(1)) ' km | ' ...
            'Min Mag: ' num2str(LOG4.minmag(1)) ' | ', ...
            'Cum. Counts (Prev. ' num2str(LOG4.t_window(1,2)) ' days)'])
        
                % highly specific, ugly code
        f = gcf;
        ax = f.Children;
        axmb = ax([1 2 3 4 6]);
        for n = 1:numel(axmb), axmb(n).ZLim = [min(latann2) max(latann2)]; axmb(n).YLim = [min(lonann2) max(lonann2)]; end
        
        % highly specific - beautifying
        axmb(4).ZTick = [axmb(4).ZTick(1) axmb(4).ZTick(end)];
        axmb(4).YTick = [axmb(4).YTick(1) axmb(4).YTick(end)];
        axmb(4).Box = 'on';
        
    end
    
end
