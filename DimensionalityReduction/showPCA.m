function [ new_features ] = showPCA( features, params, objects, indices, tests_path, folder )
%APPLYPCA Applies and shows PCA using the given number of dimensions.
%
%   params.showPCAdim --> only 2 or 3 allowed. Number of dimensions for the
%       PCA representation.
%
%   params.standarizePCA --> boolean. Standarize or not the given features.
%
%%

    result_dir = [tests_path '/PCA plots/' folder];
    mkdir(result_dir);

    %% Apply PCA
    if(params.standarizePCA)
        new_features = standarize(features);
    end
    [COEFF, ~, latent] = princomp(new_features);

    %% Transform features with new dimensionality
    new_features = new_features*COEFF(:,1:params.showPCAdim);

    %% Get label information of the samples
    labels = {};
    count = 1;
    for ind = indices'
        labels = {labels{:}, objects(ind(1)).objects(ind(2)).trueLabel};
    end
    uniqueLabels = unique(labels);
    
    labelsInd = zeros(1, length(labels)); count = 1;
    for lab = uniqueLabels
        labelsInd(ismember(labels, lab{1})) = count;
        count = count+1;
    end
    
    colormap jet;
    c = linspace(1,10,length(uniqueLabels));
    
    %% Plot data
    f = figure;
    if(params.showPCAdim == 2)
        scatter(new_features(:,1), new_features(:,2), 10, labelsInd);
    elseif(params.showPCAdim == 3)
        scatter3(new_features(:,1), new_features(:,2), new_features(:,3), 10, labelsInd);
    end
    saveas(f, [result_dir '/all_samples']);
    close(gcf);
    
    %% Apply PCA for each pair of classes
    c = colormap; close(gcf);
    c = c(round(linspace(1,size(c,1),length(uniqueLabels))), :);
    if(params.standarizePCA)
        new_features = standarize(features);
    end
    [COEFF, ~, latent] = princomp(new_features);
    new_features = new_features*COEFF(:,1:2);
        
    combs = combnk(1:length(uniqueLabels), 2);
    for comb = combs'
        this_feat = [new_features(labelsInd==comb(1),:); new_features(labelsInd==comb(2),:)];
        f = figure;
        scatter(this_feat(:,1), this_feat(:,2), 10, [repmat(c(comb(1),:), [sum(labelsInd==comb(1)) 1]); repmat(c(comb(2),:), [sum(labelsInd==comb(2)) 1])]);
        saveas(f, [result_dir '/' uniqueLabels{comb(1)} ' vs ' uniqueLabels{comb(2)}]);
        close(gcf);
    end
    
end

