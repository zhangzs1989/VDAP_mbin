function catalog = rmDuplicateEvents(catalog,OTtol)

if isempty(catalog)
    return
end

catalogO = catalog;
I = ones(numel(catalog),1);

k=0;
while sum(I)~=0 && numel(catalogO)>1
    k = k + 1;
    disp(['Pass #: ',int2str(k),'...']);
    I = findDuplicateEvents(catalogO,OTtol);
    catalogO = catalogO(~I);
end

ndup = numel(catalog) - numel(catalogO);
disp([int2str(ndup),' duplicates removed by OT tolerance of ',num2str(OTtol),' seconds'])

catalog = catalogO;

end