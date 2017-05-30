%% seismicTS_plot4_forExplosions
%{
Only plots magnitude and counts, but it draws a threshold line at the
number of earthquakes required to exceed the empirical beta threshold.

Extended off of seismicTS_plot3
Additions:
(1) incorporates TIMEMAP
(2) makes the earthquake map bigger

%}

%% PLOT ROUTINE

for l = 1:height(LOG)
    
    f = figure;
    f.Position = [56 -18 2282 677];
    
    % Moment Sub Plot
    ax(1) = subplot(2,4,1:3);
    tc = LOG.DATA(l).tc;
    binData = LOG.DATA(l).binData;
    Astart = LOG.catalog_background_time(l,1);
    Astop = LOG.catalog_background_time(l,2);
    
    plot(LOG.DATA(l).E);
    stairs(tc(1:numel(binData)), magnitude2moment(binData, 'reverse'), 'k')
    ylim([0 6])
    yticks(0:1:6);
    xlim([Astart Astop]);
    ylabel('Magnitude');
%     linkaxes(ax, 'x');

    hold('on')
    
    title({LOG.volcano_name{l}; ...
        ['Annulus: ' num2str(LOG.annulus(l,1)) ' - ' num2str(LOG.annulus(l,2)) ' km | ' ...
        'Max Depth: ' num2str(LOG.maxdepth(l)) ' km | ' ...
        'Min Mag: ' num2str(LOG.minmag(l)) ' | ', ...
        'Beta (' num2str(LOG.t_window(l,1)) ' day increment, ' num2str(LOG.t_window(l,2)) ' day window)']})

    % Counts Subplot
    ax(2) = subplot(2,4,[5:7]);
    tc = LOG.DATA(l).tc;
    counts = LOG.DATA(l).binCounts;
    be = LOG.BETA(l).be;
    be_c = beta2counts(be, LOG.BETA(l).N, LOG.t_window(l,2), LOG.BETA(l).T);
    Astart = LOG.catalog_background_time(l,1);
    Astop = LOG.catalog_background_time(l,2);
    
%     if ~isempty(LOG.DATA(l).E.max_vei)
    if ~isempty(LOG.DATA(l).E)
        
        % Color scheme stuff for explosions
        % Deal with this once we have VEIs or sizes again
%         vei_color_scheme(1,:) = [0 0 1];
%         vei_color_scheme(2,:) = [0 2/3 0];
%         vei_color_scheme(3,:) = [1 1 1/10];
%         vei_color_scheme(4,:) = [1 1/2 0];
%         vei_color_scheme(5,:) = [1 0 0];
%         vei_color_scheme(6,:) = [0.8 0 0.8];
%         vei_idx = get(LOG.DATA(l).E, 'max_vei')+1;
%         clr = nan(numel(vei_idx), 3);
%         for n = 1:size(clr,1), clr(n, :) = vei_color_scheme(vei_idx(n), :); end
    
%         plot2(LOG.DATA(l).E, clr);
%         plot2(LOG.DATA(l).E, repmat([0.75 0 0],numel(LOG.DATA(l).E),1))
            plot(LOG.DATA(l).E)

    end
        
        p(1) = stairs(tc(1:numel(counts)), counts, 'k', 'LineWidth', 2);
        xlim([Astart Astop]);
        ylabel('EQ Counts');
        
        hold on
    
    p(2) = plot([Astart Astop], [be_c be_c], ...
        'k--', 'LineWidth', 2);
    xlim([Astart Astop]);
    ylabel('EQ Counts');
    ax(2).YTick = sort([ax(2).YLim(2) be_c]);
    
    linkaxes(ax, 'x')
    
    % map
    axm = subplot(2,4,[4 8]);
    timemap(datetime2(LOG.DATA(l).CAT.DateTime), ...
        LOG.DATA(l).CAT.Latitude, LOG.DATA(l).CAT.Longitude, 'ok');
    
    linkaxes([ax(2) axm], 'x')
     
end