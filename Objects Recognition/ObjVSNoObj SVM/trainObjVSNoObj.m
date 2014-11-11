function trainObjVSNoObj( objects, classes, params, features_type, V, V_min_norm, V_max_norm, feature_params, feat_path, path_folders, prop_res )
%TRAINOBJVSNOOBJ Trains a ObjVsNoObj RBF-SVM classifier

    store_dir = [params.SVMpath];
    mkdir(store_dir);

%     %% Find 'No Object' label in classes
%     found = false; i = 1;
%     while(~found)
%         if(strcmp(classes(i).name, 'No Object'))
%             noobj_lab = classes(i).label;
%             found = true;
%         end
%         i = i+1;
%     end

    %% Find initially selected samples indices (and labels)
    nInit = 0;
    nImgs = length(objects);
    for i = 1:nImgs
        nObjs = length(objects(i).objects);
        for j = 1:nObjs
%             if(objects(i).objects(j).initialSelection == true)
                nInit = nInit+1;
%             end
        end
    end
    
    indices = zeros(nInit, 2);
    labels = zeros(nInit,1);
    count = 1;
    for i = 1:nImgs
        nObjs = length(objects(i).objects);
        for j = 1:nObjs
%             if(objects(i).objects(j).initialSelection == true)
                indices(count,:) = [i j];
                if(strcmp(objects(i).objects(j).trueLabel, 'No Object'))
                    labels(count) = params.labels(2);  % No Object
                else
                    labels(count) = params.labels(1);   % Object
                end
                count = count+1;
%             end
        end
    end
    
    %% Balance samples
    if(params.balance)
        indices_tmp = indices;
        indObj = find(labels==params.labels(1));
        indNoObj = find(labels==params.labels(2));
        nChoose = min(length(indNoObj), length(indObj));
        indices = zeros(nChoose*2, 2);
        
        % Get indices and labels
        indices(1:nChoose,:) = indices_tmp(randsample(indNoObj,nChoose),:);
        indices(nChoose+1:end,:) = indices_tmp(randsample(indObj,nChoose),:);
        labels = [ones(1,nChoose)*params.labels(2) ones(1,nChoose)*params.labels(1)];
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
    
    
    %% Train classifier
    % Normalize features first
    [features, minVal, maxVal] = normalize(features);
    
    classifier =  svmtrain(features, labels, 'kernel_function', params.kernel, 'rbf_sigma', params.sigma, 'boxconstraint', params.C, 'options', statset('MaxIter', 9999999999));

    norm_params.minValNorm = minVal; norm_params.maxValNorm = maxVal;
    save([store_dir '/classifier.mat'], 'classifier');
    save([store_dir '/norm_params.mat'], 'norm_params');

end

