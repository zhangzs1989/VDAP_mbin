function T = cfgtable()
%CFGTABLE Initializes a table to be used to store event info in the NEIC
%Subspace Detector's CFG files

warning('This code is currently not used. Its operation with other codes is untested.')

% initialize the variables held by the table
dn1 = [];
dt1 = [];
lat = [];
lon = [];
depth = [];
mag = [];
mag_type = {};
N = {};
S = {};
C = {};
L = {};
phase = {};
dn2 = [];
dt2 = [];

% initialize the table
T = table(dn1, dt1, lat, lon, depth, mag, mag_type, ...
    N, S, C, L, ...
    phase, dn2, dt2);

end

