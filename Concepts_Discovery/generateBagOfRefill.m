function [ objects, classes, ind_train, ind_test ] = generateBagOfRefill( objects, folders, i_test, nConcepts, nSamplesUsed, classes, feature_params, feat_path, path_folders, prop_res )
%GENERATEBAGOFREFILL Generates the bag of refill on the training folders
% selecting nConcepts by clustering them.

    test_folder = folders{i_test};
    
    %% Get list of training and test indices to objects
    disp('## Splitting training and test samples...');
    all_indices = getAllIndices(objects);
    
    count_train = 0;
    count_test = 0;
    ind_imgs = unique(all_indices(:,1));
    for ind = ind_imgs'
        if(strcmp(objects(ind).folder, test_folder))
            count_test = count_test + sum(all_indices(:,1)==ind);
        else
            count_train = count_train + sum(all_indices(:,1)==ind);
        end
    end
    
    ind_train = zeros(count_train,2);
    ind_test = zeros(count_test,2);
    count_train = 0;
    count_test = 0;
    for ind = ind_imgs'
        this_ind = all_indices(all_indices(:,1)==ind,:);
        if(strcmp(objects(ind).folder, test_folder))
            ind_test(count_test+1:count_test+size(this_ind,1),:) = this_ind;
            count_test = count_test + size(this_ind,1);
        else
            ind_train(count_train+1:count_train+size(this_ind,1),:) = this_ind;
            count_train = count_train + size(this_ind,1);
        end
    end
    
    %% Randomly select a subset
    nSamplesUsed = min(nSamplesUsed, size(ind_train,1));
    ind_train_selected = ind_train(randsample(1:size(ind_train,1),nSamplesUsed),:);

    %% Recover features from all samples
    fprintf('## Recovering features from %d training samples...\n', nSamplesUsed);
    [features, ~] = recoverFeatures(objects, ind_train_selected, ones(1,size(ind_train_selected,1)), NaN, NaN, NaN, NaN, feature_params, feat_path, false, 0, path_folders, prop_res, [2 0], NaN);
    features = normalize(features);
    
    %% Clustering
    disp('## Calculate similarity matrix...');
%     simil = squareform(pdist(features, 'euclidean'));
    simil = pdist(features, 'euclidean');

    disp('## Starting clustering...');
    Z = linkage(simil, 'ward');    
    clustersId = cluster(Z, 'maxclust', nConcepts, 'criterion', 'distance');
    
    %% Store resulting clusters in objects structure
    nImages = length(objects);
    % Initialize initialSelection filled in objects structure
    for i = 1:nImages
        objects(i).objects(1).initialSelection = [];
    end
    count = 1;
    for ind = ind_train_selected'
        this_label = sprintf('concept_%0.4d', clustersId(count));
        found = false;
        % Look for its labelID in the list of labels
        for j = 1:length(classes)
            if(strcmp(classes(j).name, this_label))
                id = classes(j).label;
                found = true;
            end
        end
        % Store its id as already labeled (only for this execution)
        if(~found)
            classes(length(classes)+1).name = this_label;
            classes(length(classes)).label = length(classes)-1;
            id = length(classes)-1;
        end
        % Stores the label
        objects(ind(1)).objects(ind(2)).label = id;
        % Stores a flag to indicate that it has been initially labeled
        objects(ind(1)).objects(ind(2)).initialSelection = true;

        count = count+1;
    end
    
end

