function [edgest, N, bins] = histcountst(X, varargin)
% HISTCOUNTST Over-ride for HISTCOUNTS that allows for datetime objects to
% be processed.
% If no input arguments are given, the script assumes you want to make day
% long counts and creates enough bins with the proper BinEdges to make sure
% this happens.
% Note the difference in the output arguments with HISTCOUNTS
% Note: this script is much slower than PS2TS, which accomplishes the same
% task
%
% USAGE
% [edgest, N, bins] = histcountst(X, varargin)
%
% SEE ALSO HISTCOUNTS PS2TS

X = datenum(X);

if numel(varargin)==0
    
    start = floor(X(1));
    stop = ceil(X(end));
    edges = start:stop;
    varargin{1} = edges;
    
end


[N, edges, bins] = histcounts(X, varargin{:});

edgest = datetime2(edges);
bins = datetime2(bins);

end