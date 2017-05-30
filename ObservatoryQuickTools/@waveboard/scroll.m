function scroll( obj, n, varargin )
%SCROLL Scrolls through all events on a WAVEBOARD and SHOWs n events at a
%time. Moves on to next n events after user clicks. Takes all of the
%additional input arguments accepted by WAVEFORM.

%%

w = obj.w;
wb = obj;

for j = 1:n:numel(w)
    
    endidx = min(numel(w), j+n-1);
    wb.w = w(j:endidx);
    show(wb, varargin{:})
    pause
    
end


end

