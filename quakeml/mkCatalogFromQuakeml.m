function catalog = mkCatalogFromQuakeml(varargin)

%{
Read in quakeml files and return EFIS catalog structure
inputs can be one file, or one directory path. lots to add here later..
%J. PESICEK
%}

if nargin == 1 && exist(varargin{1},'file')==2 % single quakeml file input
    
    [ ~, event ] = readQuakeML(varargin{1});
    catalog = event;
    return
    
elseif nargin == 1 && exist(varargin{1},'dir')==7 % read all quakeml files in Dir
    
    D = dir2(varargin{1},'Swarm*.xml');
    
    for l=1:numel(D)
        
        [ ~, event ] = readQuakeML(fullfile(varargin{1},D(l).name));
        
        if ~isempty(event)
            
            if isfield(event,'Magnitude')
                catalog(l) = event;
            else
                event.Magnitude = nan;
                event.MagType = [];
                catalog(l) = event;
            end

        end
    end
    
else
    error('inputs not supported')
end

end