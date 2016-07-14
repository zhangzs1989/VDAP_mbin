function f = plotResp( freq, amp, phase )
%PLOTRESP [dev] Plots amplitude and phase response curves
%   This function currently accomplishes only what is necessary to diagnose
%   the functionality of resp.m

%%

f = figure;

A = subplot(211);
a = loglog(freq(1:end-1), amp(1:end-1));
xlim([-1 100])
ylabel('Amplitude')
xlabel('Frequency')

B = subplot(212);
b = semilogx(freq(1:end-1), phase(1:end-1));
xlim([-1 100])
ylim([-180 180])
ylabel('Phase')
xlabel('Frequency')



end

