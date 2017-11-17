function [perNonDC] = getPerNonDCfromMT(MTs)

perNonDC = nan(length(MTs),1);

for j=1:length(MTs)

    MT = [MTs{j}.MRR, MTs{j}.MTT, MTs{j}.MPP, MTs{j}.MRT, MTs{j}.MTP, MTs{j}.MPR];
    
    if isempty(MT) || sum(MT)==0
        perNonDC(j) = NaN;
    end
    try
        error(mt_check(MT))
    catch
%         warning('MT error, skipping')
        continue
    end
    
    if isempty(MTs{j}.T_VAL) || isempty(MTs{j}.P_VAL) || isempty(MTs{j}.N_VAL)
       [T,P,B]=mt2tpb(MT); 
       MTs{j}.T_VAL = T(1);
       MTs{j}.P_VAL = P(1);
       MTs{j}.N_VAL = B(1);       
    end
    
    egs = [MTs{j}.T_VAL,MTs{j}.P_VAL,MTs{j}.N_VAL];
    perNonDC(j) = 1-(1-min(abs(egs))/max(abs(egs))*2);

end

perNonDC(perNonDC==0)=NaN;  %THIS is for the ones that are constrained to be zero!!
perNonDC = perNonDC * 100;

end