function [ percentDuplicates, varargout ] = check4duplicateEvents(catalog,varargin)

% OTtol = tolerance in seconds for considering events to be duplicates
% if omitted, then assumed to be == 0
% output ID vector of preferred events w/ no duplicates, if desired
if isempty(catalog)
    percentDuplicates = 0;
    if nargout == 2
        varargout{1} = [];
    end
    return
end

if isstruct(catalog)
    
    dts = datenum(extractfield(catalog,'DateTime'));
    
else
    dts = catalog;
    validateattributes(dts, {'numeric'}, ...
        {'positive','finite','vector'}, mfilename, 'dts')
    
end

if nargin == 1 || varargin{1} == 0
    %% check for duplicates by identical origin time only
    %     [C,IA,IC] = unique(dts);
    
    OTtol = 0;
    percentDuplicates = (1-length(unique(dts))/length(dts))*100;
    
    if percentDuplicates > 0
        warning([num2str(100-percentDuplicates),'% unique event times'])
    end
    % quick and dirty result
    
end
if nargin == 2
    OTtol = varargin{1} ;
    validateattributes(OTtol, {'numeric'}, ...
        {'nonnegative','finite','scalar'}, mfilename, 'OTtol')
    
    minOTdiff = nan(length(dts),1);
%     minOTdiff(1) = min(abs(dts(1) - dts(2:end)));
%     minOTdiff(end) = min(abs(dts(end) - dts(1:end-1)));
%     
    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(poolobj)
        poolsize = 0;
    else
        poolsize = poolobj.NumWorkers;
    end
    
    if poolsize > 0
        
        parfor i=1:length(dts)
            
            I = false(length(dts),1);
            I(i) = true;
            dts2 = dts(~I);
            [minOTdiff(i),~] = min(abs(dts(i) - dts2));
            
        end
        
    else
        warning('No parpool, this will be slow...')
        for i=1:length(dts)
            
            I = false(length(dts),1);
            I(i) = true;
            dts2 = dts(~I);
            [minOTdiff(i),~] = min(abs(dts(i) - dts2));
            
        end
        
    end
    minOTdiff = minOTdiff*24*60*60;
    percentDuplicates = sum(minOTdiff<=OTtol)/length(dts) *100;
    
elseif nargin > 2
    error('too many input arguments')
end

if nargout == 2
    % return indices of duplicate events
    ID = findDuplicateEvents(catalog,OTtol);
    varargout{1} = ID;
    
end

end

