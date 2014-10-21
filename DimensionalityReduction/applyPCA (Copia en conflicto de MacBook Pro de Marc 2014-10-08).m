function [ new_features ] = applyPCA( features, params )
%APPLYPCA Applies PCA using the given parameters.
%
%   params.minVarPCA --> value between 0 and 1. Minimum variance covered by
%       the chosen transformed dimensions.
%
%   params.standarizePCA --> boolean. Standarize or not the given features.
%
%%

    %% Apply PCA
    if(params.standarizePCA)
        features = standarize(features);
    end
    [COEFF, ~, latent] = princomp(features);

    %% Get variables with a minimum of minVar of the variance
    dim = 0; var = 0;
    while(params.minVarPCA > var)
        dim = dim+1;
        var = sum(latent(1:dim))/sum(latent);
    end

    %% Transform features with new dimensionality
    new_features = features*COEFF(:,1:dim);

end

