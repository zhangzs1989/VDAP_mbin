function H = MTplot1(vinfo, t1, t2, catalog, mapdata, params,ii)

% Extract all necessary data from the catalog
if size(catalog,2) > 0 && ~isempty(catalog)
    Lat = extractfield(catalog, 'Latitude');
    Lon = extractfield(catalog, 'Longitude');
    Depth = extractfield(catalog, 'Depth');
    DateTime = datenum(extractfield(catalog, 'DateTime'));
    Magnitude = extractfield(catalog, 'Magnitude');
    Moment = magnitude2moment(Magnitude); % convert each magnitude to a moment
    eq_plot_size = rescaleMoments(Moment,[5 100],[-1 5]); % base event marker size on moment (a way to make a log plot)
else
    Lat = [];
    Lon = [];
    Depth = [];
    DateTime =[];
    Magnitude = [];
    eq_plot_size = [];
end

try
    mts = extractfield(catalog,'MT');
catch
    mts = [];
end

max_depth = -(abs(params.DepthRange(2))); % ensure that the value is negative

%% Figure Prep
longannO = mapdata.longann;
latannO = mapdata.latann;
%map axes
%% plot moment tensors here???
if ~isempty(mts)
    
    mt=[];
    for i=1:length(mts)
        if ~isempty(cell2mat(mts(i)))
            imt = cell2mat(mts(i));
            imt = [imt.MRR imt.MTT imt.MPP imt.MRT imt.MTP imt.MPR imt.Latitude imt.Longitude];
            if length(imt)==8
                mt = [mt; imt];
            end
        end
    end
end
if exist('mt','var') && ~isempty(mt)
    scrsz = get(groot,'ScreenSize');
    H = figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(3)/2],'visible',params.visible);
    hold on,
    
    plotmt(mt(:,8),mt(:,7),mt(:,1:6),'radius',0.05), axis equal tight off;%
    plot(Lon, Lat,'k.');
    % plotmt(mt(:,8),mt(:,7),mt(:,1:6),'radius',2,'parent',ax); %
    
    %           plotmt has compatibility issues with contourf -v6 that I don't want to deal with yet
    %           plots MT correctly in separate figure but cannot put it on the
    %           map yet, abort
    hold off

else
    H = [];
end
end