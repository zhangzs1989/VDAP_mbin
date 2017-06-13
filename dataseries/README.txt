README -- DATASERIES MANUAL
% First written: 2017 June 13

DATASERIES IS INTENDED TO PROCESS THE FOLLOWING INPUT FILES:
(1) earthquake catalog of located events ('master_catalog.mat' | 'catalog_mat' | '..._catalog.mat')
(2) earthquake catalog of unlocated events ('trigger.mat')
(3) explosion start/stop dates | eruption start/stop dates
(4) network down times

DATASERIES expects the following conventions in the input files:

1. For the located earthquake catalog:
n-by-6 table with Variables:
-DateTime
-Latitude
-Longitude
-Depth
-Magnitude
-Type

2. For the unlocated earthquake catalog:
n-by-6 table with Variables:
-DateTime
-Latitude
-Longitude
-Depth
-Magnitude
-Type

* NOTE: The formats for #1 and #2 are the same. This makes it easier for
DATASERIES to merge catalogs and work with both of them. If the raw file
that you are given does not conform to these naming standards, then adjust
accordingly before throwing it into DATASERIES.
* For both #1 and #2, if there are no data for a particular field, the
default values should be (for each Variable)
-DateTime -- NaT (although this should never happen)
-Latitude -- NaN
-Longitude -- NaN
-Depth -- NaN
-Magnitude -- NaN
-Type -- {''}
* For both #1 and #2, a completely empty file should return
>> example_catalog

example_catalog =

  0×6 empty table
