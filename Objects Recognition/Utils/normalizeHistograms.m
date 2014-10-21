function [ X ] = normalizeHistograms( X )
%NORMALIZEHISTOGRAMS Normalizes row-wise.
%   Normalizes the values of the input matrix row-wise instead of
%   column-wise.

    sum_row = sum(X,2);
    X = bsxfun(@rdivide, X, sum_row);
end

