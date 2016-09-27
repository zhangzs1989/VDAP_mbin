%% QC PLOTs of FPs and TPs, etc

disp('QC')
files = subdir(fullfile(params.outDir, 'eruptionData.mat'));
qcdir = 'FPs/';
[SUCCESS,MESSAGE,MESSAGEID] = mkdir([params.outDir,filesep,qcdir]);
bviz = 'invisible';
bfigs = false;
wingPlot = false;
minVEIb = params.VEI(1) ;
% vsort = [1 3 6 8 5 7 9 4 2]; % sort volcanoes by type instead of alphabet
% vsort = 1;
vsort = 1:size(files,1);% don't do anything special to sort the volcanoes
pdatar1 = {'volcano','TruePositives','FalsePositives','TrueNegatives','nEruptions'};
beta_ax = 2; % axis w/in beta figure for adding new anom lines

for w=1:numel(params.ndays_all) % which window size to plot?
    
    win = params.ndays_all(w);
    lh = [];  tpvscm =[]; fpvscm = []; ntp = 0; nfp=0; outPdata = {};
    
    pdata = zeros(length(files),4);
    
    for n = vsort % 1:size(files,1)
        
        load(files(n).name)
        istr = strfind(files(n).name,'/');
        vname = files(n).name(istr(end-1)+1:istr(end-0)-1);
        lh =[lh; {vname}];
        disp(vname)
        vqcdir=[params.outDir,filesep,vname,filesep,qcdir];
        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(vqcdir);
        
        %how many with long enough repose?
        reposes = extractfield(eruptionData,'yrsInRepose'); % including those after last eruption
        ereposes = extractfield(eruptionData(1:end-1),'yrsInRepose'); %only those before eruptions
        
        ir = (reposes > params.repose);
        eir= (ereposes > params.repose);
        
        %which VEIs to plot
        VEI = extractfield(eruptionData,'VEI');
        
        
        if sum(ir)>0 && sum(VEI>=minVEIb) > 0
            
            %         nerupts = sum(ir); %size(eruptionData,2) - 1;
            
            fps = (extractfield(eruptionData(ir),'falsePositives'));
            tps = (extractfield(eruptionData(ir),'truePositives'));
            fpMaxBc = (extractfield(eruptionData(ir),'FalsPosMaxVals'));
            tpMaxBc = (extractfield(eruptionData(ir),'TruePosMaxVals'));
            
            TP = sum(tps(w:numel(params.ndays_all):end)); % #TPs
            FP = sum(fps(w:numel(params.ndays_all):end)); % #FPs
            NE = sum(eir);
            
            TN = NE - TP;
            
            pdata(n,1) = TP;
            pdata(n,2) = FP; % negative just for plotting prettiness
            pdata(n,3) = TN;
            pdata(n,4) = NE;
            
            % want to maximize this score function, which I came up with by
            % trial and error.  Need a better one.  This is starting to
            % feel like an inverse problem
            %             pdata(n,5) = TP/NE - FP/NE - TN/NE + 1;
            
            if bfigs
                F = openfig([params.outDir,filesep,vname,filesep,vname,'_Beta_ANSS'],'new',bviz);
                t1o=F.Children(beta_ax).XLim(1);
                t2o=F.Children(beta_ax).XLim(2);
            end
            
            %% plot wing plot and beta plot around false positives
            if wingPlot || bfigs
                vinfo = getVolcanoSpecs(vname,inputFiles,params);
                [ catalog_b, outer, inner] = filterAnnulusm(catalog, vinfo.lat, vinfo.lon, params.srad); % filter annulus
                
                for b=1:size(eruptionData,2)
                    try
                        % loop over false positives
                        t1=cell2mat(eruptionData(b).FalsPosStart(w));
                        t2=cell2mat(eruptionData(b).FalsPosStop(w));
                        
                        t1b=cell2mat(eruptionData(b).FalsPosMaxStart(w));
                        t2b=t1b + params.ndays_all(w);
                        maxBcs = cell2mat(eruptionData(b).FalsPosMaxVals(w));
                        
                        plot_windows = [t1 t2];
                        plot_names=[]; cm = [];
                        for s = 1:numel(t1)
                            if ~isnan(t1(s)) || ~isnan(t2(s))
                                str=['FP',int2str(s),'period',int2str(b),'_win',int2str(win)];
                                plot_names=[plot_names,{str}];
                                
                                mp = (t1(s)+t2(s))/2;
                                mp2= (t1b(s)+t2b(s))/2;
                                if bfigs
                                    plot(F.Children(beta_ax),[mp mp],[F.Children(beta_ax).YLim(1) F.Children(beta_ax).YLim(2)],'m--',[mp2 mp2],[F.Children(beta_ax).YLim(1) F.Children(beta_ax).YLim(2)],'m-')
                                    text(F.Children(beta_ax),mp2,maxBcs(s),num2str(maxBcs(s)))
                                    xlim([t1(s)-params.AnomSearchWindow t2(s)+params.AnomSearchWindow]);
                                    print(F,'-dpng',[vqcdir,filesep,vinfo.name,'_Beta_',str])
                                end
                                
                            else
                                disp('No FP')
                            end
                            
                            
                        end
                        if sum(sum(isnan(plot_windows))) == 0 && ~isempty(plot_windows) && wingPlot
                            [fh_wingplot] = prepAndDoWingPlot(vinfo,params,inputFiles,catalog_b,outer,inner,plot_windows,plot_names);
                            close(fh_wingplot)
                        end
                    catch
                        eruptionData(b).FalsPosStart
                        error('plots around False Positives DIDNOTWORK')
                    end
                    
                    %% now true positives
                    try
                        t1=cell2mat(eruptionData(b).TruePosStart(w));
                        t2=cell2mat(eruptionData(b).TruePosStop(w));
                        t1b=cell2mat(eruptionData(b).TruePosMaxStart(w));
                        t2b=t1b + params.ndays_all(w);
                        maxBcs = cell2mat(eruptionData(b).TruePosMaxVals(w));
                        
                        plot_windows = [t1 t2];
                        plot_names=[]; cm = [];
                        for s = 1:numel(t1)
                            if ~isnan(t1(s)) || ~isnan(t2(s))
                                str=['TP',int2str(s),'period',int2str(b),'_win',int2str(win)];
                                plot_names=[plot_names,{str}];
                                
                                mp = (t1(s)+t2(s))/2;
                                mp2= (t1b(s)+t2b(s))/2;
                                if bfigs
                                    plot(F.Children(beta_ax),[mp mp],[F.Children(beta_ax).YLim(1) F.Children(beta_ax).YLim(2)],'c--',[mp2 mp2],[F.Children(beta_ax).YLim(1) F.Children(beta_ax).YLim(2)],'c-')
                                    text(F.Children(beta_ax),mp2,maxBcs(s),num2str(maxBcs(s)))
                                    xlim([t1(s)-params.AnomSearchWindow t2(s)+params.AnomSearchWindow]);
                                    print(F,'-dpng',[vqcdir,filesep,vinfo.name,'_Beta_',str])
                                end
                                
                            else
                                disp('No TP')
                            end
                        end
                        
                    catch
                        eruptionData(b).FalsPosStart
                        error('plots around True Positives DIDNOTWORK')
                    end
                    
                    if bfigs
                        plot(F.Children(beta_ax),[eruptionData(b).t0_repose eruptionData(b).t0_repose],[F.Children(beta_ax).YLim(1) F.Children(beta_ax).YLim(2)],'LineStyle','-.', 'LineWidth', 2, 'Color', [0.5 0.5 0.5])
                    end
                    
                end
                
            end
            %         figure(F.Number)
            if bfigs
                figure(F)
                xlim([t1o t2o])
                savefig(F,[params.outDir,filesep,vname,filesep,vname,'_Beta_FPwin',int2str(win)]);
                print(F,'-dpng',[vqcdir,filesep,vname,'_Beta_FPwin',int2str(win)])
                close(F)
            end
            
        end
    end
    %     save([params.outDir,filesep,'ScoreStats_',int2str(win)],'pdata')
    outPdata(:,1) = lh;
    outPdata = [pdatar1; lh num2cell(pdata)];
    %     s6_cellwrite([params.outDir,filesep,'ScoreStats_',int2str(win),'.csv'],outPdata);
    
    if strcmp(params.visible,'off')
        close all
    end
    
    try
        fig1=figure('visible',params.visible);
        clf(fig1)
        hax = axes('parent',fig1);
        
        h = barh(hax,pdata(vsort,[4 1 2]),'hist');
        set(hax,'yticklabel',lh,'fontsize',15)
        
        h(1).FaceColor = [.8 0 0 ];  %'red';
        h(3).FaceColor = 'cyan';
        h(2).FaceColor = [0.25,0.5,0.9];
%         set(hax,'XTick',[0:4])
%         xlim([-4 4])
        xlabel('Count')
        title({[int2str(win),' day beta window']; [int2str(params.AnomSearchWindow),' day pre-eruption search window']; [int2str(params.repose),' year repose required']; ['VEI >= ',int2str(minVEIb)]})
        %     title({'Beta Stats'; [int2str(win),' day beta window']; [int2str(params.AnomSearchWindow),' day pre-eruption search window']; [int2str(params.repose),' yr repose time']; ['score: ',int2str(sum(pdata(:,5)))]})
        
        %     legend('True Positives','False Positives','True Negatives','Eruptions','location','best')
        legend('Eruptions','True Positives','False Positives','location','bestOutside')
        
        
        print([params.outDir,filesep,qcdir,filesep,'BetaStatsWinVEI',int2str(minVEIb),'_',int2str(win)],'-dpng')
    end

    %         figure('visible',params.visible);
    %         subplot(1,2,2)
    %         hist(fpvscm,1:.5:10)
    %         xlim([1 9])
    %         title(['FPs (',int2str(win),' day window)'])
    %         subplot(1,2,1)
    %         hist(tpvscm,1:.5:10)
    %         xlim([1 9])
    %         title(['TPs (',int2str(win),' day window)'])
    %         print([params.outDir,filesep,qcdir,filesep,'TPsVsFPs_Win',int2str(win)],'-dpng')
    
    clear outData
    ct = 1;
    outData(1,:) = {'volcano','lat','lon','elev','Eruptions','TP','FP'};
    for i=1:numel(lh)
        ct = ct +1;
        volcname = lh(i);
        vinfo = getVolcanoSpecs(volcname,inputFiles,params);
        outData(ct,1) = volcname;
        outData(ct,2) = {vinfo.lat};
        outData(ct,3) = {vinfo.lon};
        outData(ct,4) = {vinfo.elev};
        outData(ct,5) = {pdata(vsort(i),4)};
        outData(ct,6) = {pdata(vsort(i),1)};
        outData(ct,7) = {pdata(vsort(i),2)};
        
        
    end
    s6_cellwrite([params.outDir,filesep,'FPs/FPvolcResultsVEI',int2str(minVEIb),'_',int2str(params.ndays_all(w)),'.csv'],outData,',')
end


%%
