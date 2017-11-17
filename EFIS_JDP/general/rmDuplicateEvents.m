function catalog = rmDuplicateEvents(catalog,OTtol)

catalogO = catalog;
I = ones(numel(catalog),1);

while sum(I)~=0
    I = findDuplicateEvents(catalogO,OTtol);
    catalogO = catalogO(~I);
end

catalog = catalogO;

end