function eruptionCat = VEIcatalogFilter(eruptionCat,params)

%% narrow eruption catalog by VEI

max_vei=extractfield(eruptionCat,'VEI_max');

I = max_vei >= params.VEI(1) & max_vei <= params.VEI(2);
% I = logical([1;I]);
eruptionCat = eruptionCat(I,:);
if sum(I)>0
    volcs=(unique(extractfield(eruptionCat,'volcano')))';
%     disp(volcs)
    disp([int2str(sum(I)),' eruptions with VEI >= ',int2str(params.VEI(1)),' at ',int2str(numel(volcs)),' volcanoes'])
else
    disp('No eruptions fit criteria')
end