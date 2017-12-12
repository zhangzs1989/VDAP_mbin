function catalog = rmDuplicateEvents(catalog,OTtol)

catalogO = catalog;
I = ones(numel(catalog),1);

while sum(I)~=0
    I = findDuplicateEvents(catalogO,OTtol);
    catalogO = catalogO(~I);
end

ndup = numel(catalog) - numel(catalogO);
disp([int2str(ndup),' duplicates removed by OT tolerance of ',num2str(OTtol),' seconds'])

catalog = catalogO;

end