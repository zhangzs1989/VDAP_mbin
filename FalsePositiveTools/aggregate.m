%% aggregate

sust_anomaly_dates = []; % there has to be a better way to initialize this
sust_anomaly_binlen = [];
sust_anomaly_precursor_days = [];
sust_anomaly_repose_days = [];
sust_max_bcBe = [];
sust_mean_bcBe = [];


for z = 1:numel(B(1).bin_sizes)
    
    aa = []; % there has to be a better way to initialize this
    bb = [];
    cc = [];
    dd = [];
    ee = [];
    ff = [];
    
    for n = 1:numel(B)
        
        if hasdata(B(n))
            
            aa = [aa; B(n).sust_anomaly_dates{z}];
            bb = [bb; B(n).sust_anomaly_binlen{z}];
            cc = [cc; B(n).sust_anomaly_precursor_days{z}];
            dd = [dd; B(n).sust_anomaly_repose_days{z}];
            
            val_max = B(n).sust_max_bcBe{z}'; val_mean = B(n).sust_mean_bcBe{z}';
            ee = [ee; val_max];
            ff = [ff; val_mean];
            
            sust_anomaly_dates{z}           = {aa};
            sust_anomaly_binlen{z}          = {bb};
            sust_anomaly_precursor_days{z}  = {cc};
            sust_anomaly_repose_days{z}     = {dd};

            sust_max_bcBe{z}                = {ee};
            sust_mean_bcBe{z}               = {ff};
            
        end
        
    end
    
end


%%





