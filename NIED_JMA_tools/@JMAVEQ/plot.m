function f = plot( obj )
%PLOT Plots event counts per day at a volcano

if ~strcmpi(obj.VN,'Kirishimayama')

f = figure;
f.Position = [1000 918 1200 750];
try
dt = obj.C.DateTime;
T = obj.C;
catch
end
ax(1) = subplot(5,1,1);
p(1) = stairs(dt, T.A, 'k');
ylabel('A-type')
title([obj.VN ' timeseries'])

ax(2) = subplot(5,1,2);
all_b_types = sum(T{:, {'B' 'BH' 'BL' 'BT' 'BS'}}, 2);                      
p(2) = stairs(dt, all_b_types, 'b');
ylabel('B-type')

ax(3) = subplot(5,1,3);
all_tremor = sum(T{:, upper({'T' 'TC' 'Tk' 'TP'})}, 2);                      
p(3) = stairs(dt, all_tremor, 'g');
ylabel('Tremor')

ax(4) = subplot(5,1,4);
all_exp = sum(T{:, {'DL'}}, 2);                      
p(5) = stairs(dt, all_tremor, 'r');
ylabel('DLF')

ax(5) = subplot(5,1,5);
all_exp = sum(T{:, upper({'EX' 'Tex' 'Air' 'Pyr'})}, 2);                      
p(5) = stairs(dt, all_tremor, 'r');
ylabel('Explosions, PF, Infra')

linkaxes(ax, 'x')
zoom('xon')

% adjust axis to cover data across all subplots
% fix bottom of Y axis at 0
timeax = nan(numel(ax), 2); % initialize timeax as an n-by-2 matrix
for i = 1:numel(ax)
    timeax(i, :) = ax(i).XLim; % get X axes limits for ax(i)
    ax(i).YLim(1) = 0; % set Y axis bottom at 0
end
ax(5).XLim = [min(timeax(:, 1)) max(timeax(:, 2))]; 

end

end