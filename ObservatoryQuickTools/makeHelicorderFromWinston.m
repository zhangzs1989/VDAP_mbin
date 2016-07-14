function makeHelicorderFromWinston(ds, tag, tstart, tstop, output_dir)
% MAKEHELICORDERFROMWINSTON Grabs data from a Winston and produces day long
% helicorder
% 
% HARD-CODED:
% + helicorder properties (i.e., minutes per line, duration, etc.) -
% Currently hard-coded to do one day with 30 mpl
%   POSSIBLE SOLUTION - simply make a helicorder object an input variable
%   so that the user can pre-define this stuff
% + filterObject - filtering properties are hardCoded in here (because I am 
% developing this for rapid use at Turrialba) 
%   POSSIBLE SOLUTION - make the filter an input variable as a varargin
%
% INPUT:
% + ds - datasource - 
% + tag - ChannelTag -
% + tstart - datenum - 
% + tstop - datenum -
% + output_dir - string - 
%
% OUTPUT:
% + prints an figure window and saves the figure and associated jpg to
% output_dir
%

%% Hard-coded variables

load('colors.mat')

    % User parameters - instrument code & output directories
nslc = tag.string;
mkdir output_dir;
nslc_output_dir = [output_dir nslc '/'];
mkdir(nslc_output_dir)

filterObj = filterobject('L',2,4); % comment this line to not use filter

%% run

t = tstart;

% grabs one day of data at a time, filters if applicable, plots helicorder, and saves helicorder image
while(t <= tstop)

    w = waveform(ds, ChannelTag(nslc), t, t+1); % get one day of data
    
    if which('filterObj')
        
        display('Filtering data...')
        wunfiltered = w;
        w = demean(wunfiltered); % demean data so that it is centered at 0
        w = fillgaps(w, 0, NaN); % replace NaN values with 0
        w = filtfilt(filterObj, w);
        filterStr = sprintf('Filtered: %s, %1.1f Hz, %d poles', get(filterObj, 'Type'), get(filterObj, 'Cutoff'), get(filterObj, 'Poles'));
        
    end
    
    heli = helicorder(w); % create the helicorder object
    heli.mpl = 30;
    heli.trace_color = colors.earthworm;
    build(heli) % display the helicorder
    if which('filterObj'), ax = gca; ax.Title.String = {ax.Title.String; filterStr}; end
    saveas(gcf,[nslc_output_dir datestr(t,'yyyy-mm-dd') '.jpg']) % save jpg
    savefig(gcf,[nslc_output_dir datestr(t,'yyyy-mm-dd') '.fig']) % save Matlab figure
    
    t = t+1; % increment time by 1 day
    close all

end