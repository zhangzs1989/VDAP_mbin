function cfg = rdcfg( filename )
%RDCFG Reads a .cfg file from the NEIC Subspace Detector. Returns a
%Configuration object.
% Note: Does NOT read in event data

%%

% filename = '/Volumes/ALBERTA/GOLDENTICKET1/UWHSR__subspace.cfg'; % stub

warning('RDCFG can only handle one file at a time.')

fid = fopen(filename);

cfg = Configuration();
cfg.T = table;
% next two lines separates file path into project name and cfg name
path = fileparts(filename);
[cfg.project_folder, cfg.name] = fileparts(path);
nwt = 0; % number of waveform templates
ne = 0; % number of events

while true
    
    tline = fgets(fid);
    if tline==-1, break, end;
    
    if ~isempty(strfind(tline, ':'))
    
        idx = strfind(tline, ':');
        prop = tline(1:idx(1)-1);
        val = strtrim(tline(idx(1)+1:end));
        
        switch lower(prop)
            
            case 'bandpass'
                
                cfg.bandpass = val;
            
            case 'sample_rate'
                
                cfg.sample_rate = val;
                
            case 'start_stop'
                
                cfg.start_stop = val;
                
            case 'acquisition_parameters'
                
                cfg.acquisition_parameters = val;
                
            case 'inputcwb'
                
                cfg.inputcwb = val;
                
            case 'detectionthreshold_parameters'
                
                cfg.detectionthreshold_parameters = val;
                
            case 'template_parameters'
                
                cfg.template_parameters = val;
                
            case 'output_path'
                
                cfg.output_path = val;
                
            case 'station_coordinates'
                
                cfg.station_coordinates = val;
                
            case 'centroid_location'
                
                cfg.centroid_location = val;
                
            case 'source_receiver_distance'
                
                cfg.source_receiver_distance = val;
                
            case 'radial_distance'
                
                cfg.radial_distance = val;
                
            case 'channels'
                
                cfg.channels = val;
                
            case 'location_code'
                
                cfg.location_code = val;
                
            case 'waveform_templates'
                
                nwt = nwt + 1;
                cfg.waveform_templates{nwt} = val;
                
            case 'output_files'
                
                cfg.output_files = val;
                
                % assume that a line with text but no valid property is event info
            otherwise
                
                ne = ne + 1;
                
                current_date = datevec(now);
                current_year = current_date(1);
                current_year = datenum(current_year, 1, 1);
                
                data = textscan(tline, '%s %s %s %f %f %f %f %s %s %s %s %s %s %s %s %s');
%                 cfg.T.name = data{1}
                date1 = data{2};
                time1 = data{3};
                dn1 = datenum(date1) + datenum(time1, 'HH:MM:SS') - current_year;
                dt1 = datetime(datestr(dn1));
                cfg.T{ne, 'dn1'} = dn1;
                cfg.T{ne, 'dt1'} = dt1;
                cfg.T{ne, 'lat'} = data{4};
                cfg.T{ne, 'lon'} = data{5};
                cfg.T{ne, 'depth'} = data{6};
                cfg.T{ne, 'mag'} = data{7};
                cfg.T{ne, 'mag_type'} = data{8};
                cfg.T{ne, 'N'} = data{9};
                cfg.T{ne, 'S'} = data{10};
                cfg.T{ne, 'C'} = data{11};
                cfg.T{ne, 'L'} = data{12};
                cfg.T{ne, 'phase'} = data{13};
                date2 = data{14};
                time2 = data{15};
                dn2 = datenum(date2) + datenum(time2, 'HH:MM:SS') - current_year;
                dt2 = datetime(datestr(dn2));
                cfg.T{ne, 'dn2'} = dn2;
                cfg.T{ne, 'dt2'} = dt2;
                if ne==1, cfg.svd_indep = data{16}{:}; end;
                
        end
        
        
    end
    
end

end

