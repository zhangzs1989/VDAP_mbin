classdef Configuration
    %CONFIGURATION Holds all information from a CFG file for the NEIC Subspace
    %Detector
    %   For the current implementation of Configuration, all values are 
    %   stored as strings.
    %
    % Data Management Properties
    %
    % project_folder    : parent folder for conducting a project with the
    %                       Subspace Detector
    % name              : name of folder where all cfg files and results
    %                       from preprocess and detect will be stored. It
    %                       is recommended that this folder be given a name
    %                       followed by an incremented number. E.g.,
    %                       'Analysis0'. Specific functionality for
    %                       incrementing the enumerated part of this name
    %                       will be implemented in the future.
    %              
    % T                 : table of events
    %
    % Processing Properties
    %
    % svd_indep         : 'svd' to compute the singular value decomposition
    %                      of all events listed in the cfg file
    %                     'indep' treats every event in the cfg file as a
    %                       template
    %                     (used by preprocess)
    %
    %
    %
    
    properties
        
        project_folder = './';
        name = 'subspace_test';
        
        T; % Table of event lines
        
        svd_indep = ''; % run preprocessor as 'svd' or as 'indep' (independent)
        
        % user options
        bandpass;
        inputcwb;
        output_path;
        station_coordinates;
        sample_rate;
        location_code;
        channels;
        start_stop; % format-> 2015/05/20-00:00:00 2015/06/01-00:00:00
        acquisition_parameters;
        detectionthreshold_parameters; % 0.65 1800.0 9.0 constant
        template_parameters; % 600.0 5.0 5.0 -0.1
        centroid_location; % 0.0 0.0 1.0
        source_receiver_distance; % 12422.058
        radial_distance; % 10.0
        waveform_templates; % {1-by-m} cell array of filepaths
        output_files; noccresults
        
    end
    
    properties(Dependent)
        
        filepath;
        folderpath;
        
    end
    
    methods
        
        % set methods
        function obj = set( obj, prop, varargin)
            
            switch lower(prop)
                
                case 'waveform_template'
                    
                    % provide a single sac file
                    % >> str = '/Volumes/ALBERTA/Raung_test1/Analysis0/template0_0.sac'
                    % >> set( cfg, 'waveform_template', str)
                    
                    % provide directory of sac files
                    % >> str = '/Volumes/ALBERTA/Raung_test1/Analysis0/*sac'
                    % >> set( cfg, 'waveform_template', str)
                    
                    str = varargin{1};
                    d = dir(str);
                    
                case 'inputcwb'
                    
                    % >> set(cfg, 'inputcwb', datasource('winstont', 'localhost', 16022);
                    
                    ds = varargin{1};
                    obj.inputcwb = [get(ds, 'server') ' ' num2str(get(ds, 'port'))];
                    
                case 'bandpass'
                    
                    % pass a filterobject as the input
                    % >> set( cfg, 'bandpass', filterobject('B', [2 8], 3);
                    
                    fo = varargin{1};
                    cutoff = get(fo, 'cutoff');
                    poles = get(fo, 'poles');
                    obj.bandpass = [num2str(cutoff(1)) ' ' ...
                        num2str(cutoff(2)) ' ' num2str(poles)];
                    
                case 'station_coordinates'
                    
                    latlondep = varargin{1};
                    obj.station_coordinates = [num2str(latlondep(1)) ' ', ...
                        num2str(latlondep(2)) ' ' num2str(latlondep(3))];
                    
                case 'start_stop'
                    
                    % final result needs to be in the following format:
                    % 2015/05/20-00:00:00 2015/06/01-00:00:00
                    
                    warning('Input should be [datenum datenum]')
                    ss = varargin{1}; %% ss should be a [start stop] input
                    start = ss(1);
                    stop = ss(2);
                    start = datenum(start);
                    start = datestr(start, 'yyyy/mm/dd-HH:MM:SS');
                    stop = datestr(stop, 'yyyy/mm/dd-HH:MM:SS');
                    obj.start_stop = [start ' ' stop];
                    
                otherwise
                    
                    error([prop ' is not a valid property.'])
                    
            end
            
            
        end
        
        % get method for filepath
        function val = get_filepath( obj )
            
            error('This section of code should not be used. Delete it once you are sure all calls to it have been deleted.')
            val = fullfile( obj.project_folder, obj.name, 'preprocess.cfg');
            
        end
        
        % get method for folderpath
        function val = get_folderpath( obj )
            
            val = fullfile( obj.project_folder, obj.name, '/' );
            
        end
        
        % get channel tag strings from list of template inputs
        % specific format of NS_
        function val = get_NS_strs( obj )
            
            info = obj.T{:, {'N', 'S', 'L', 'C'}};
            for n = 1:numel(info)
                if strcmp(info{n}, '..'), info{n} = '--'; end;
            end
            
            for n = 1:size(info, 1)
                str{n} = [info{n, 1} '.' info{n, 2} '.' info{n, 3} '.' info{n, 4}];
            end
            
            str = unique(str);
            tag = ChannelTag(str);
            
            for n = 1:numel(tag)
                
                val{n} = [tag(n).network tag(n).station '_'];
                
            end
            
        end
        
    end
    
end

