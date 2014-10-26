function [ objects nObj nNoObj ] = applyObjVSNoObj( objects, classes, objVSnoobj_params, features_type, V, V_min_norm, V_max_norm, feature_params, feat_path, path_folders, prop_res )
%APPLYOBJVSNOOBJ Applies the build ObjVSNoObj classifier using the initial
% selection samples on the rest of the samples.

    classifier = [];
    norm_params = [];
    load('ObjVSNoObj SVM/classifier.mat'); % load 'classifier'
    load('ObjVSNoObj SVM/norm_params.mat'); % load 'norm_params'

    %% Find 'No Object' label in classes
    found = false; i = 1;
    while(~found)
        if(strcmp(classes(i).name, 'No Object'))
            noobj_lab = classes(i).label;
            found = true;
        end
        i = i+1;
    end
    

    %% Find all not initial samples (and labels for validation)
    if(objVSnoobj_params.evaluate)
        labels = {};
    end
    
    nEmpty = 0;
    nImgs = length(objects);
    for i = 1:nImgs
        nObjs = length(objects(i).objects);
        for j = 1:nObjs
            if(isempty(objects(i).objects(j).initialSelection))
                nEmpty = nEmpty+1;
            end
        end
    end
    
    indices = zeros(nEmpty, 2);
    count = 1;
    for i = 1:nImgs
        nObjs = length(objects(i).objects);
        for j = 1:nObjs
            if(isempty(objects(i).objects(j).initialSelection))
                indices(count,:) = [i j];
                count = count+1;
            end
        end
    end
    
    if(objVSnoobj_params.evaluate)
        labels = cell(1, size(indices,1));
        count = 1;
        for ind = indices'
            labels{count} = objects(ind(1)).objects(ind(2)).trueLabel;
            count = count+1;
        end
	end

    
    %% Recover features for training samples
    val = zeros(size(indices,1),1); t=0; histClasses = val; show_easiest = false; tests_path = '';
    % ORIGINAL
    if(strcmp(features_type, 'original'))
        [appearance_feat, event_feat] = recoverFeatures(objects, indices, val, V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res, [1 0], tests_path);
    % CONVOLUTIONAL NEURAL NETWORKS
    elseif(strcmp(features_type, 'cnn') || strcmp(features_type, 'cnn_con'))
        [appearance_feat, event_feat] = recoverFeatures(objects, indices, val, V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res, [2 0], tests_path);
        % CNN object candidate + CNN scene
        if(strcmp(features_type, 'cnn_con'))
            [appearance_feat] = concatenateCNN(appearance_feat, sceneFeatures, indices);
        end
    % LSH DIM. REDUCED
    elseif(strcmp(features_type, 'lshDimReduc')) 
        error('lshDimReduc features not implemented for ObjVSNoObj SVM classifier.');
    end
    features = [appearance_feat event_feat];
    
    %% Normalize features wrt training samples
    features = normalize(features, norm_params.minValNorm, norm_params.maxValNorm);
    
    
    %% Apply classification
    nSamp = size(features,1);
    % Prepare variables for 'parfor'
    ind_tmp = round(linspace(0,nSamp,50));
    all_ind = {};
    for i = 1:(length(ind_tmp)-1)
        all_ind{i} = (ind_tmp(i)+1):ind_tmp(i+1);
    end
    res = cell(length(all_ind),1);
    for i = 1:length(all_ind)
        res{i} = zeros(length(all_ind{i}), 1);
    end

    % Parallel for
    parfor i = 1:length(all_ind)
%         [res{i}, ~, ~] = svmpredict(ones(length(all_ind{i}),1), features(all_ind{i},:), classifier, '-q');
        res{i} = svmclassify(classifier, features(all_ind{i},:));
    end
    % Put all results in 'results'
    results = zeros(nSamp,1);
    for i = 1:length(all_ind)
        results(all_ind{i}) = res{i};
    end
    
    nObj = 0; nNoObj = 0;
    if(objVSnoobj_params.evaluate)
        TP = 0; FP = 0; FN = 0; TN = 0;
    end
    
    count = 1;
    for r = results'
        if(r == objVSnoobj_params.labels(2))
            % Assign 'No Object' label to sample
            objects(indices(count,1)).objects(indices(count,2)).label = noobj_lab;
            % Separate as if it were initial selection
            objects(indices(count,1)).objects(indices(count,2)).initialSelection = true;
            nNoObj = nNoObj+1;
            if(objVSnoobj_params.evaluate)
                if(strcmp(labels{count}, 'No Object'))
                    TN = TN+1;
                else
                    FN = FN+1;
                end
            end
        else
            nObj = nObj+1;
            if(objVSnoobj_params.evaluate)
                if(~strcmp(labels{count},'No Object'))
                    TP = TP+1;
                else
                    FP = FP+1;
                end
            end
        end
        count = count+1;
    end
    
    %% Evaluation results
    if(objVSnoobj_params.evaluate)
        disp(['TP = ' num2str(TP) ', TN = ' num2str(TN) ', FP = ' num2str(FP) ', FN = ' num2str(FN)]);
    end
end

