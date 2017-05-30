%% prepare for printing

f = gcf;
f.PaperPositionMode = 'auto';
f.Units = 'centimeters';
f.PaperUnits = 'centimeters';
f.PaperOrientation = 'Landscape';
f.PaperSize = [ 35 10];
f.Position(3:4) = [34 6.5];

ax = f.Children;
ax(5).Title.FontSize = 15;
ax(6).FontSize = 15;
ax(5).FontSize = 15;
ax(4).FontSize = 15;
ax(5).LineWidth = 2;
ax(4).LineWidth = 2;
ax(6).LineWidth = 2;
ax(4).Title.String = '30 km rad.';
ax(6).FontSize = 15;
f.PaperSize = [ 35 10];
f.Position(3:4) = [30 6.5];
ax(5).Location = 'northwest';

ax(6).Position(1) = 0.08;
ax(6).Position(2) = 0.15;
ax(6).Position(4) = 0.7;

ax(1).Position(1) = 0.8;
ax(2).Position(1) = 0.8;
ax(3).Position(1) = 0.8;
ax(4).Position(1) = 0.8;
ax(7).Position(1) = 0.8;

ax(1).Position(4) = 0.7;
ax(2).Position(4) = 0.7;
ax(3).Position(4) = 0.7;
ax(4).Position(4) = 0.7;
ax(7).Position(4) = 0.7;

ax(1).Position(2) = 0.15;
ax(2).Position(2) = 0.15;
ax(3).Position(2) = 0.15;
ax(4).Position(2) = 0.15;
ax(7).Position(2) = 0.15;


print(f, '-depsc2','/Users/jaywellik/Desktop/SSA2017_figs_epsc2/test','-painters')
% saveas(f, '/Users/jaywellik/Desktop/SSA2017_figs_epsc2/test2','epsc2')