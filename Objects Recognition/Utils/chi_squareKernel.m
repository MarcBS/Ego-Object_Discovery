function [ val ] = chi_squareKernel( X, Y )
%CHI_SQUAREKERNEL Applies the chi-square kernel over to arrays of values X
% and Y.

    % No 0s allowed
    X(X==0) = 1e-10; Y(Y==0) = 1e-10;
    
    %% Version 1
%     val = 1 - sum(( (X-Y).^2 ) ./ ( 0.5 * (X+Y) ));

    %% Version 2
    gamma = 1/length(X);
    val = exp(-gamma * sum(( (X-Y).^2 ) ./ (X+Y) ));

end

