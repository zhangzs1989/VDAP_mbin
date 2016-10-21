function writecfg( cfg, filepath )
%WRITECFG Writes a Configuration object to a cfg file
% overwrites existing files.
% filepath must be the full path to the .cfg file.
%
% USAGE
% >> writecfg( preproccfg, '/Users/.../preprocess.cfg')
%
% SEE ALSO Configuration rdcfg

%% Generate lines for file - do not write yet

T = cfg.T; % Extract table from the Configuration obj

% write event data to lines
for n = 1:numel(T.dn1)
    
    t = T(n, :);
    lines{n} = sprintf('%s %s %2.4f %2.4f %2.2f %2.2f %s %s %s %s %s %s %s', ...
        'name', ...
        datestr(t.dn1, 'yyyy/mm/dd HH:MM:SS'), t.lat, t.lon, t.depth, ...
        t.mag, t.mag_type{:}, ...
        t.N{:}, t.S{:}, t.C{:}, t.L{:}, ...
        t.phase{:}, datestr(t.dn2, 'yyyy/mm/dd HH:MM:SS'));
    
end
lines{1} = [lines{1} ' ' cfg.svd_indep]; % append 'svd' or 'indep' to 1st line

% add additional inputs
lines{numel(lines)+1} = ' ';
if ~isempty(cfg.bandpass), lines{numel(lines)+1} = ['bandpass: ' cfg.bandpass]; end
if ~isempty(cfg.sample_rate), lines{numel(lines)+1} = ['sample_rate: ' cfg.sample_rate]; end
if ~isempty(cfg.start_stop), lines{numel(lines)+1} = ['start_stop: ' cfg.start_stop]; end
if ~isempty(cfg.acquisition_parameters), lines{numel(lines)+1} = ['acquisition_parameters: ' cfg.acquisition_parameters]; end
if ~isempty(cfg.inputcwb), lines{numel(lines)+1} = ['inputcwb: ' cfg.inputcwb]; end
if ~isempty(cfg.detectionthreshold_parameters), lines{numel(lines)+1} = ['detectionthreshold_parameters: ' cfg.detectionthreshold_parameters]; end
if ~isempty(cfg.template_parameters), lines{numel(lines)+1} = ['template_parameters: ' cfg.template_parameters]; end
if ~isempty(cfg.output_path), lines{numel(lines)+1} = ['output_path: ' cfg.output_path]; end
if ~isempty(cfg.station_coordinates), lines{numel(lines)+1} = ['station_coordinates: ' cfg.station_coordinates]; end
if ~isempty(cfg.centroid_location), lines{numel(lines)+1} = ['centroid_location: ' cfg.centroid_location]; end
if ~isempty(cfg.source_receiver_distance), lines{numel(lines)+1} = ['source_receiver_distance: ' cfg.source_receiver_distance]; end
if ~isempty(cfg.radial_distance), lines{numel(lines)+1} = ['radial_distance: ' cfg.radial_distance]; end
if ~isempty(cfg.channels), lines{numel(lines)+1} = ['channels: ' cfg.channels]; end
if ~isempty(cfg.location_code), lines{numel(lines)+1} = ['location_code: ' cfg.location_code]; end
if ~isempty(cfg.waveform_templates),
    for n = 1:numel(cfg.waveform_templates)
        lines{numel(lines)+1} = ['waveform_templates: ' ...
            cfg.waveform_templates{n}];
    end
end
if ~isempty(cfg.output_files), lines{numel(lines)+1} = ['output_files: ' cfg.output_files]; end

%% Write lines to file

fid = fopen( filepath, 'w'); % overwrites existing files
for n = 1:numel(lines)
   fprintf(fid, '%s\n', lines{n});    
end

end