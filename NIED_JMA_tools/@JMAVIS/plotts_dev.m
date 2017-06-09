function f = plotts_dev( obj )
%PLOTTS Plots a time series of column height (in subjective and objective
%terms) when data are available.
%   ! IN DEVELOPMENT !

for i = 1:numel(obj)
    
    if ~isempty(obj(i).Data)
        
        f = figure;
        f.Position(3:4) = [1020 420]; % make long rectangle
        
        yyaxis left
        
        p(1) = plot(obj(i).Data.DATETIME, str2double(obj(i).Data.H), 'ob');        
        ylabel('Quantitative Column Height'); zoom('xon')
        title(obj(i).VN);
        
        yyaxis right
        p(2) = stairs(obj(i).Data.DATETIME, obj(i).Data.Q, 'r', ...
            'LineWidth', 2);
        ylabel('Qualitative Column Height'); zoom('xon')
        
        % put asterisk on eruptions
        idx = find(strcmpi(obj(1).Data.EVENT, 'Er'), 1000000000);
        try
            if ~isempty(idx)
                hold on
                p(3) = plot(obj(i).Data.DATETIME(idx), zeros(numel(idx), 1)+7, '*r');
            end
        catch
        end
        ylim([0 10])
        
    end
    
end


end

