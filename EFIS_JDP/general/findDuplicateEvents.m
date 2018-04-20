function ID = findDuplicateEvents(catalog,OTtol)
%{
find duplicate events w/i some tolerance. If duplicates are found,
the one with the larger mag is taken.

requires a 'DateTime' field and 'Magnitude' fields only
J. PESICEK
%}
validateattributes(OTtol, {'numeric'}, ...
    {'nonnegative','finite','vector'}, mfilename, 'OTtol')

if isempty(catalog)
    ID = [];
    return
end
%%
dts = datenum(extractfield(catalog,'DateTime'));

minOTdiff = nan(length(dts),1);
ID = zeros(length(dts),1);

poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    poolsize = 0;
else
    poolsize = poolobj.NumWorkers;
end

if poolsize > 0
    
    parfor i=1:length(dts)
        
        dts2 = dts;
        dts2(i) = NaN;
        [minOTdiff(i),ID(i)] = min(abs(dts(i) - dts2));
        
    end
    
else
    
    for i=1:length(dts)
        
        dts2 = dts;
        dts2(i) = NaN;
        [minOTdiff(i),ID(i)] = min(abs(dts(i) - dts2));
        
    end
    
end
minOTdiff = minOTdiff*24*60*60;

%%
% now you have the OTdiffs and the indices, cycle thru and pick the best
% event:
ID2 = false(numel(dts),1);
for i=1:numel(dts)
    if minOTdiff(i) > OTtol
        ID2(i) = true;
    else
        % check both events
        e1 = i;
        e2 = ID(i);
        
        if (isnan(catalog(e1).Magnitude) && isnan(catalog(e2).Magnitude))
            catalog(e1).Magnitude = 0.1;
        end
        
        % pick one with bigger mag
        if catalog(e1).Magnitude == catalog(e2).Magnitude
            if isfield(catalog,'dist') % added for filtering based on proximity of other feature (i.e. volcano)
                
                disp('choosing preferred event based on DIST field')
                if catalog(e1).dist < catalog(e2).dist
                    catalog(e1).Magnitude = catalog(e1).Magnitude + .01;
                else
                    catalog(e2).Magnitude = catalog(e2).Magnitude + .01;
                end
                
            else
                warning('Mags are same, choosing preferred event arbitrarily')
                catalog(e1).Magnitude = catalog(e1).Magnitude + .01;
            end
        end
        if catalog(e1).Magnitude > catalog(e2).Magnitude || isnan(catalog(e2).Magnitude)
            ID2(i) = true;
        end
    end
end

% change to IDs of dups
ID = ~ID2;

%% testing, remove later
% [ percentDuplicates] = check4duplicateEvents(catalog(~ID)); %no OTtol, here, otherwise infinite loop
% if percentDuplicates > 0
%     error('FATAL ERROR')
% end
end