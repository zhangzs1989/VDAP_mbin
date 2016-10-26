function axh = show( obj, varargin )
%SHOW Shows (or plots) waveform objects on a waveboard
% accepts all optional input arguments that are accepted by waveform.
% This function makes use of the SQUISHY routine, which is a command
% written by VDAP
%
% SEE ALSO waveform squishY

for n = 1:numel(obj.w)

    subplot(numel(obj.w),1,n);
    plot(obj.w(n), varargin{:});
    ax(n) = gca;
    ax(n).Title.String = '';
    if n==1, ax.Title.String = 'Waveboard'; end
    ax(n).YTick = [];
    ax(n).YLabel.String = '';
    
end

if strcmp(obj.squishY, 'on')
    % remove vertical spaces between subplot axes
    f = gcf;
    axtmp = f.Children;
    axtmp = squishY(axtmp);
end

axh = ax;

end

