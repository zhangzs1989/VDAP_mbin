function varargout = decode_mcvco(wave,varargin)

%DECODE_MCVCO: Locates and decodes test cycle produced by a McVCO
%
%MCVCO TEST CYCLE SUMMARY: Total test cycle duration is fixed at 53.25
%  seconds consisting of 3 consecutive pieces:
%  [1] High Amplitude 21.25 Hz tone (duration: 10.25 seconds)
%  [2] Series of 8 Mass drops (duration: 18 seconds)
%  [3] Binary train of 25 bits (duration: 25 seconds)
%
%USAGE:
% sst = decode_mcvco(wave,'sst')     --> Start/Stop Times of test cycle
% data = decode_mcvco(wave,'data')   --> Binary String
% resp = decode_mcvco(wave,'resp')   --> Instrument Response, this returns
%                                        the trimmed waveform between the 
%                                        tone and the binary data
% bvl = decode_mcvco(wave,'bvl')     --> Battery Voltage Level
% [sst resp bvl] = decode_mcvco(wave,'sst','resp','bvl') --> Any combo
%
%INPUTS: wave    - a waveform object with a calibration pulse
%        command - user defined: 'sst', 'data', 'resp', or 'bvl'
%
%OUTPUTS: start - cal pulse start time (1x1 double)
%         sst   - cal pulse start/stop times (1x2 double)
%         data  - bit data from signal (1x25 boolean)
%         gain  - instrument gain (1x1 double)
%         id    - instrument ID (1x1 double)
%         resp  - instrument response data (1x1 waveform)
%         bvl   - battery voltage levels (1x1 double)
%         amp   - tone amplitude (from Goertzel Algorithm)


%% INITIALIZATIONS
if ~isempty(wave)
v = get(wave,'data');
tv = get(wave,'timevector');
Fs = get(wave,'freq');
v_l = get(wave,'data_length');

chk_per = Fs*5;         % Check Period (look for tone every 5 seconds)
chk_dur = Fs*1;         % Check Duration (look for 1 second)
tone_freq = 21.25/Fs;   % 21.25 Hz tone normalized to Fs
tone_found = 0;         % Has tone been found?         
edge_found = 0;         % Has right edge of tone been found?
n = 1;                  % Ref to left edge of window

%% LOOK FOR RIGHT EDGE OF 21.25 Hz Tone
while (edge_found==0) && ((n+(18+25)*Fs) < v_l)
   chk_v = v(n:n+chk_dur-1);   % Window to check for tone
   chk_v = chk_v - nanmean(chk_v);
   s = gmax(chk_v,tone_freq);
   if (s < 10000) && (tone_found == 0)
      n = n+chk_per;
   elseif (s > 10000) && (tone_found == 0)
      tone_found = 1;
      max_s = s;
      off = nanmean(chk_v);
   elseif (tone_found == 1) && (edge_found == 0)
      if s > max_s
         max_s = s;
         off = nanmean(chk_v);
         n = n + 1;
      elseif s < max_s*(.75)
         edge_found = 1;
      else
         n = n + 1;
      end
   elseif tone_found == 0
      n = n+chk_per;
   end
end

%% CREATE A SECOND LISTENER WINDOW SUCH THAT THE MIDDLE OF THE SECOND IS
%  10.25 SECONDS BEFORE THE MIDDLE OF THE FIRST. BALANCE THE OUTPUT OF THE
%  GOERTZEL ALGORITHM FROM THE 2 WINDOWS TO LOCATE AN EXACT FRONT EDGE AND
%  BACK EDGE OF THE 10.25 SECOND TONE

if edge_found
    flag = 0;
    m = n-10.25*Fs;
    if m < 1
        edge_found = 0;
        bin_data = [];
    else
        while flag == 0
            chk_left = v(m:m+chk_dur-1);
            sl = gmax(chk_left,tone_freq);
            chk_right = v(n:n+chk_dur-1);
            sr = gmax(chk_right,tone_freq);
            if sl>sr
                flag = 1;
                t1 = floor(m+chk_dur/2); % Tone Edge 1
                t2 = floor(n+chk_dur/2); % Tone Edge 2
                if (t1-2*Fs)<1
                    pre = [];
                    pre_start = 1;
                else
                    pre = nanmean(v(t1-2*Fs:t1-Fs));
                    pre_start = t1-2*Fs;
                end
                k = floor(t2 + 18.75*Fs);
                if k+25*Fs <= v_l
                    for K = 1:25
                        bin_data(K) = v(k)>off;
                        bin_ref(K) = k;
                        k = k + Fs;
                    end
                else
                    bin_data = [];
                end
            else
                m = m+1;
                n = n+1;
            end
        end
    end
end
else % No Waveform
    edge_found = 0;
    bin_data = [];
end

%%
if (edge_found == 1) && (numel(bin_data) == 25) && k+.25*Fs+10 <= numel(tv)
   complete = 1;
else
   complete = 0;
end

%% USER-DEFINED OUTPUTS
d2s = 1/24/60/60;
for n = 1:numel(varargin)
    if complete
        switch(lower(varargin{n}))
            case{'start','begin'}
                varargout{n} = tv(t1);
                
            case{'sst','startstoptimes'}
                varargout{n} = [tv(t1), tv(t1)+53.25*d2s];
                
            case{'dat','data'}
                varargout{n} = {bin_data};
                
            case{'gain'}
                varargout{n} = 42 + 6*bin2dec(num2str(bin_data(1:3)));
                
            case{'id'}
                varargout{n} = bin2dec(num2str(bin_data(4:13)));
                
            case{'wav','wave','waveform'}
                varargout{n} = extract(wave,'INDEX',pre_start,t1+55.25*Fs);
                
            case{'mdrp','massdrops','rspw','response_waveform'}
                varargout{n} = extract(wave,'INDEX',t2,t2+18*Fs);
                
            case{'off','offset','offset_amplitude'}
                varargout{n} = off-pre;
                
            case{'bvl','voltage','voltages','battery_voltage'}
                varargout{n} = bin2dec(num2str(bin_data(14:25)))/79;
                
            case{'tamp','toneamp','tone_amplitude'}
                tone = extract(wave,'INDEX',t1+1*Fs,t1+9*Fs);
                varargout{n} = (max(tone)-min(tone))/2;    
                
            case{'ramp','respamp','response_amplitude'}
                pre = median(extract(wave,'INDEX',t2,t2+Fs));
                resp = extract(wave,'INDEX',t2+round(.75*Fs),...
                                            t2+round(2.25*Fs));
                varargout{n} = max(resp)-pre;
                
            case{'plot'}
                fh = figure;
                plot(extract(wave,'INDEX',t1-Fs,k+.25*Fs+Fs))
                hold on
                scatter((bin_ref-t1+Fs)/Fs,v(bin_ref),'*','r')  
                varargout{n} = fh;
        end
    else
        varargout{n} = NaN;
    end
end

%% Compute Goertzel Algorithm
function s = gmax(chk_v,tone_freq)
s = zeros(numel(chk_v)+2,1);
for m = 1:numel(chk_v)
   s(m+2)=chk_v(m)+2*cos(2*pi*tone_freq)*s(m+1)-s(m);
end
s = max(abs(s));






    
    