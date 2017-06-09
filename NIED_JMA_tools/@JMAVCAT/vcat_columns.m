function C = vcat_columns
%VCAT_COLUMNS Produces a cell array of column names for the JMAVCAT objects

% This is the template from JMAVIS
% C = upper({'DateTime', 'Event', 'Col', 'Q', ...
%     'H', 'Dir', 'Loc', 'Remark'});

C = upper({'DateTime', 'No', 'Type', 'Opoint', 'Dur', 'Remark'});

end