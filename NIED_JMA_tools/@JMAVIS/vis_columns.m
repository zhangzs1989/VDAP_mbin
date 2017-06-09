function C = vis_columns
%VIS_COLUMNS Produces a cell array of column names for the Visual
%Observations table

C = upper({'DateTime', 'Event', 'Col', 'Q', ...
    'H', 'Dir', 'Loc', 'Remark'});

end