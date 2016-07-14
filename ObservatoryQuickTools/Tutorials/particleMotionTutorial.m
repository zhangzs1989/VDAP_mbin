%% particleMotionTutorial

%%

display(' ')
display('This tutorial shows how to use the particle motion tutorial.')
display('You need to be connected to the internet for this tutorial to work.')
display(' ')

%%

ds = datasource('irisdmcws');
start = datenum('2016/04/27 04:19:21'); % (*JP fav)
station = 'VICA';
tag = ChannelTag({['OV.' station '.--.HHZ'], ... % 5. regional station
                  ['OV.' station '.--.HHN'], ...
                  ['OV.' station '.--.HHE'], ...
                  });
fo = filterobject('H', 0.7, 4);              
w = waveform(ds, tag, start, start+60/86400);
w = filtfilt(fo, w);
particleMotion(w);

display('Try zooming and panning across the waveform axis panel to see')
display('how the particle motion updates automatically.')



%%