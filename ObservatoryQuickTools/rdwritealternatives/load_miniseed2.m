function w = load_miniseed(request)
   %LOAD_MINISEED loads a waveform from MINISEED files
   % combineWaves isn't currently used!
   
   % Glenn Thompson 2016/05/25 based on load_sac
   % request.combineWaves is ignored
   
   if isstruct(request)
      [thisSource, chanInfo, startTimes, endTimes, ~] = unpackDataRequest(request);
      for i=1:numel(chanInfo)
         for j=1:numel(startTimes)
            thisfilename = getfilename(thisSource,chanInfo(i),startTimes(j));
            w(i,j) = mseedfilename2waveform(thisfilename{1}, startTimes(j), endTimes(j));
         end
      end
      w = w(:);
      
   else
      %request should be a filename
      thisFilename = request;
      if exist(thisFilename, 'file')
        w = mseedfilename2waveform(thisFilename);
      else
          w = waveform();
          warning(sprintf('File %s does not exist',thisFilename));
      end
   end
end

function w = mseedfilename2waveform(thisfilename, snum, enum)


st = ReadMSEEDFast(thisfilename); % written by Martin Mityska

for n = 1:numel(st)
    
    s = st(n);
    
    w(n) = waveform();
    w(n).data = s.data;
    w(n).start = epoch2datenum(s.startTime);
    w(n).Fs = s.sampleRate;
    w(n).cha_tag = ChannelTag(s.network, s.station, s.location, s.channel);
%     w(n) = extract(w(n), 'time', snum, enum);
    
end

end
