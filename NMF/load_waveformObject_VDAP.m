function [waveform_output] = load_waveformObject_VDAP(ds,scnl,startTime,endTime,sampleRate)

% warning('ON','all')

%     [dsta,db,ds,Net,basename] = db_index(idatabase);
%     disp(sprintf('getw: entering %s database',basename));

%     disp('calling waveform(ds,scnl,startTime,endTime)');
%ds
%     get(scnl,'station'), get(scnl,'channel'), get(scnl,'network'), get(scnl,'location')
%     disp([datestr(startTime),' to ',datestr(endTime)])
try
    w = waveform(ds,scnl,startTime,endTime);
    if isempty(sampleRate);
        sampleRate=get(w,'freq');
    end
    w2=align(w,startTime,sampleRate);
    %--temporary solution to go around "trload_css" failure for uaf_continuous database--
    %         if isempty(w) && strcmp(basename,'uaf_continuous')
    %             disp('*****"trload_css" failed, do the workaround*****');
    %             w = waveform(ds,scnl,startTime,endTime,true);
    %             w2=align(w,startTime,sampleRate);
    %         end
    %------------------------------------------------------------------------------------
catch
    disp('No waveform loaded')
    w2 = [];
end
waveform_output=w2;
end
