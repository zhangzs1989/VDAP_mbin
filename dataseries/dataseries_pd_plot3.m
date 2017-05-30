%% dataseries_pd_plot3
%{
* Plots proximal seismicity vs. distal seismicity. In general, just
compares two different annuli.

* Extended off of dataseries_pd_plot2
1. Brings back proximal seismicity. Puts it on the R axis.
2. Does not plot empirical thresholds of any sort

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
        f.Position = [0.0367 -0.1413 1.5 0.3];
        
        ax(1) = subplot(1,4,1:3);
        plot(LOG4.DATA(1).E);
        
        for i = 1:height(LOG4)
            
            % get data for plots
            if sum(LOG4.annulus(i,:) - [0 2]) == 0 % equivalence statement
                ptc = LOG4.DATA(i).tc;
                pcounts = LOG4.DATA(i).binCounts;
%                 pbe = LOG4.BETA(i).be;
%                 pbe_c = beta2counts(be, LOG4.BETA(i).N, LOG4.t_window(i,2), LOG4.BETA(i).T);
                ptime = LOG4.DATA(i).CAT.DateTime;
                plat = LOG4.DATA(i).CAT.Latitude;
                plon = LOG4.DATA(i).CAT.Longitude;

            elseif sum(LOG4.annulus(i,:) - [2 30]) == 0 % equivalence statement
                dtc = LOG4.DATA(i).tc;
                dcounts = LOG4.DATA(i).binCounts;
%                 dbe = LOG4.BETA(i).be;
%                 dbe_c = beta2counts(be, LOG4.BETA(i).N, LOG4.t_window(i,2), LOG4.BETA(i).T);
                dtime = LOG4.DATA(i).CAT.DateTime;
                dlat = LOG4.DATA(i).CAT.Latitude;
                dlon = LOG4.DATA(i).CAT.Longitude;                

            end
            
        end
        
        % Timeseries Plot
        ax(1) = subplot(1,4,1:3);
        yyaxis(ax(1), 'left')
        p(1) = stairs(dtc, dcounts, 'k', 'LineWidth', 2); hold on;
        ax(1).YAxis(1).Color = 'k';
        ax(1).YAxis(1).Label.String = 'Distal Counts';
        
        yyaxis(ax(1), 'right')
        p(2) = stairs(ptc, pcounts, 'b', 'LineWidth', 2); hold on;
        ax(1).YAxis(2).Color = 'k';
        ax(1).YAxis(2).Label.String = 'Prox. Counts';
        
        legend(p([2 1]), 'Proximal Seismicity', 'Distal Seismicity')
        
        title(ax(1), [LOG4.volcano_name{1} ' | ' ...
            'Max Depth: ' num2str(LOG4.maxdepth(1)) ' km | ' ...
            'Min Mag: ' num2str(LOG4.minmag(1)) ' | ', ...
            'Cum. Counts (Prev. ' num2str(LOG4.t_window(1,2)) ' days)'])
        
        % Map plot
        [latann1, lonann1] = reckon(vinfo.lat(1), vinfo.lon(1), km2deg(2), 0:360);
        [latann2, lonann2] = reckon(vinfo.lat(1), vinfo.lon(1), km2deg(30), 0:360);
        
        axm = subplot(1,4,4);
        axmb(1) = timemap(datetime2(ptime), plat, plon, 'ob');
        axmb(2) = timemap(datetime2(dtime), dlat, dlon, 'ok');
        axmb(3) = timemapoverlay(axm, vinfo.lat(1), vinfo.lon(1), '^r', 'MarkerFaceColor', 'r');
        axmb(4) = timemapoverlay(axm, latann1, lonann1, 'r', 'LineWidth', 2);
        axmb(5) = timemapoverlay(axm, latann2, lonann2, 'r', 'LineWidth', 2);
        axmb(6) = timemapunderlay(axm, [plat; dlat], [plon; dlon], ...
            'o', 'Color', [0.67 0.67 0.67]);
        axm.Color = 'none'; for n = 1:numel(axmb)-1, axmb(n).Color = 'none'; end
        linkaxes([ax(1) axm], 'x')        

        % highly specific, ugly code
        f = gcf;
        fax = f.Children;
        axmb = fax([1 2 3 4 7]);
        for n = 1:numel(axmb), axmb(n).ZLim = [min(latann2) max(latann2)]; axmb(n).YLim = [min(lonann2) max(lonann2)]; end
        
        % highly specific - beautifying
        axmb(4).ZTick = [axmb(4).ZTick(1) axmb(4).ZTick(end)];
        axmb(4).YTick = [axmb(4).YTick(1) axmb(4).YTick(end)];
        axmb(4).Box = 'on';
        
    end
    
end
