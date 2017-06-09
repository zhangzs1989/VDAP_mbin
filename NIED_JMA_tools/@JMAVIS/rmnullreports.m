function obj = rmnullreports( obj )
%RMNULLREPORTS Removes lines from JMAVIS.Data that do not report any
%eruptive activity
%   There is a line for a report at 0900h and 1500h every day. Sometimes,
%   those reports contain no information about eruptive activity. This
%   function removes those lines to cut down on space.
%   
%   Current rules that are in place are marked with a *
%       *obj.Data.EVENT must be empty
%       obj.Data.COL must be empty
%       *obj.Data.Q must be NaN
%       obj.Data.H must be empty
%
% USAGE
% >> % V == a volcano object with a visual observation table stored in V.Data
% >> V = rmnullreports(V);

for i = 1:numel(obj)
    
    T = obj(i).Data; rmidx = [];
    for r = 1:height(T)
        
        try
            % if everything is empty
%             if isempty(T.EVENT{r}) && isempty(T.COL{r}) && isnan(T.Q(r)) && isempty(T.H{r})
            if isnan(T.Q(r)) && isempty(T.EVENT{r})
                rmidx = [rmidx; r]; % append this row to the list of null rows that need to be removed
            end
        catch
        end
        
    end
    T(rmidx, :) = []; % remove null rows
    obj(i).Data = T;
    
end

end

