%         xlabel('Years in Repose')
%         ylabel('Years until Eruption')
%         title('% Chance of True Positive')
%         colorbar

figure;
% p = imagesc(forecast_matrix, 'AlphaData', 0.75);
[p, hcb] = imagesc2(forecast_matrix, jet(20), [0.75 0.75 0.75]);
% forecast_matrix(isnan(forecast_matrix)) = -1; % change cells with no anomaly data to -1; these will be plotted as grey
% caxis([0 1])
p.AlphaData = 0.75;
hcb.Location = 'northoutside';
% cb.Label.String = '% Chance Anomaly Leads to Eruption';
title({'% Chance that an Anomaly Leads to Eruption'; strjoin(params.volcanoes, ', '); [num2str(bin_lengths(bin)) ' day beta window | Min VEI: ' num2str(params.minVEI)]})
xlabel('If the volcano has been in repose for R years...', 'FontWeight', 'bold')
ylabel('An eruption will occur within N years of the anomaly...', 'FontWeight', 'bold')
p.Parent.XTick = 1:numel(repose_min);
p.Parent.XTickLabel = repose_min;
p.Parent.YTick = 1:numel(forecast_time);
p.Parent.YTickLabel = forecast_time;



%% annotate True Positive matrix plot

% text(1:numel(repose_min), 1:numel(forecast_time), [num2str(tp_matrix(1:numel(repose_min),1:numel(forecast_time))) ' of ' num2str(tp_matrix(1:numel(repose_min), 1:numel(forecast_time))+fp_matrix(1:numel(repose_min), 1:numel(forecast_time)))])

for r = 1:numel(repose_min)
    for f = 1:numel(forecast_time)
        text(r, f, [num2str(tp_matrix(f,r)) ' of ' num2str(tp_matrix(f,r)+fp_matrix(f,r))], 'HorizontalAlignment', 'center')
    end
end