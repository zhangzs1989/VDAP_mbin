%{
pull new data, then rebuild complete ISC catalog, then filter to
volcanoes only

For now this is just a recipe, not a script. Could automate later..

NOTE that we are only using REVIEWED ISC data, not the full bulletin, which
means most recent data is not available.

1)
wgetISC4aYear.sh 2017
    creates month long csv, log, and kmz files 

2)
processYrCatalogs.sh iscCatalogAll6.csv
    creates single master ISC csv file

3)
importISCcatalog.m
    imports ISC master CSV file and creates .mat catalog file in EFIS
    format. Takes a long time to read in data.

4)
wgetISCFMs4aYear.sh 2017

5)
processFM_YrCatalogs.sh iscFMcatAll6.csv

6)
importISC_FMs.m 

7)
combineCatAndFMs.m

8)
trimCat2Poly2.m
    this creates the final master catalog with FMs and trimmed to volcanoes

%}
