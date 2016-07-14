%% quickLocalHostImport

%% USER SUPLLIED INFO

tags = ChannelTag({'RC.MLLR.--.EHZ', 'RC.MLLR.--.EHN', 'RC.MLLR.--.EHE'})
t1 = '2014/11/11 13:56:00';
t2 = '2014/11/11 13:58:00';



%% AUTOMATIC

ds = datasource('winston', 'localhost', 16022);
w = waveform(ds, tags, t1, t2);