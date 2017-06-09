%% Plot and Compare Visual Observations w ISC Catalogs

catalog_dir = '/Users/jaywellik/Documents/VolcanoData/catalogs/'; %"Barrier, The"/ISC_catalog*.mat';
D = struct2table(dir(catalog_dir));
D = D(D.isdir, :);


for v = 1:numel(VIS)
    
    figure;
    
    D2 = D(strcmpi(D.name, VIS(v).VN), :);
    
    % if there is an ISC catalog
    if ~isempty(D2)
        
        fulldir = fullfile(D2.folder{1}, D2.name{1});
        catalog_fileformat = fullfile(fulldir, 'ISC*.mat');
        files = dir(catalog_fileformat);
        load(fullfile(files.folder, files.name))

        ax(1) = subplot(2,1,1);
        T = struct2table(catalog_a);

        if ~isempty(T)
            T.DateTime = datetime(T.DateTime);
            t1 = datetime('2008/01/01', 'InputFormat', 'yyyy/MM/dd');
            t2 = datetime('2014/03/01', 'InputFormat', 'yyyy/MM/dd');
            T = T(T.DateTime >= t1 & T.DateTime < t2, :);
            
            plot(T.DateTime, T.Magnitude, 'ok'); hold on
        end
        plot(VIS(v).Data.DATETIME, str2double(VIS(v).Data.H), 'ob')

        
        ax(2) = subplot(2,1,2);
        if ~isempty(T), plot(T.DateTime, T.Magnitude, 'ok'); hold on; end
        plot(VIS(v).Data.DATETIME, VIS(v).Data.Q, 'ob');
        
        
        linkaxes(ax, 'x')
        zoom('xon')
        
    else
        
        disp([VIS(v).VN ' does not have a catalog in the Dropbox folder.'])
        
    end
    
    
end

%%