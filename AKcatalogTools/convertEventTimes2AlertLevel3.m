function [ alert_level ] = convertEventTimes2AlertLevel3( JP_events )
%CONVERTEVENTSTIMES2ALERTLEVELS 
% This is is a very specific code that converts the EventTimes cell array
% that JP designed into the structure that is understood by
% addAlertLevel2Plot()

%%

A = alertLevelChron;
A.schema = createSchema('avo');


A.tdnum = datenum(JP_events(:, 1));
A = sort(A);
A.str = JP_events(:, 4);
A.num = zeros(size(A.str));
A = fillNum(A);
A = fillClr(A);

alert_level = A;