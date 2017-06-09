%% NIED_VIS_tutorial

load('/Users/jaywellik/Documents/MATLAB/VDAP_mbin/NIED_JMA_tools/@JMAVIS/VIS.mat') % -> VIS

visT = obj2table(VIS);

% select the index that corresponds to a particular volcano
% '4' -> Aira/Sakurajima
% '7' -> Asosan
% '2' -> Kuchinoerabujima
% '5' -> Kirishimayama
% '6' -> Unzendake
ThisVolcano = VIS(7);

% Display all visual observation data
ThisVolcano.Data;

% remove null reports from Visual Observation Table
ThisVolcano = rmnullreports(ThisVolcano);

% Display all pertinent Visual Observations from ThisVolcano
ThisVolcano.Data;

% Display all observations that occurred in yyyy/mm
T1 = ThisVolcano.Data(...
    ThisVolcano.Data.DATETIME >= datetime(2011,09,01) & ...
    ThisVolcano.Data.DATETIME < datetime(2016,1,1),:)

% T1 = T1(strcmpi(T1.EVENT, 'Er') & strcmpi(T1.LOC, 'S'), :)
% 
% t2 = T1(~strcmpi(T1.REMARK, 'End'), :); height(t2)
% t3 = T1(strcmpi(T1.REMARK, 'Start'), :); height(t3)
