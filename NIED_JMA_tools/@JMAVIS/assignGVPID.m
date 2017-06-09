function obj = assignGVPID( obj, database )
%ASSIGNGVPID Overload function for JMAVIS
% Assigns the Volcano ID numbers to the JMAVIS object
%
% USAGE
% >> VIS = JMAVIS.assignGVPID( VIS, jp_volcanoes);

[vid, vnum, off_name] = assignGVPID(database, get(obj, 'VN'));
obj = set(obj, 'VID', vid);

end

