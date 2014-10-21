function [ val ] = chi_squareKernel2( X, Y )
%CHI_SQUAREKERNEL Applies the chi-square kernel over to arrays of values X
% and Y.

    val = exp(- ( (X-Y).^2 ) ./ (X+Y) );

end

