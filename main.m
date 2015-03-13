
%%%%%%%%%%
%
% Uncomment the first line "loadParameters;" if you are not applying a
% test_battery.
%
%%%%%%%%%%
%% Load parameters
% loadParameters;

%% Go through each folder getting list of images and labels
disp('# PARSING FOLDERS looking for all images...');
[ list_path, list_img, list_event, list_event2 ] = parseFolders( folders, path_folders, format, path_labels );


%% Build 'objects' structure
if(~do_abstract_concept_discovery)
    if(reload_objStruct)
        disp('# BUILD OBJECTS STRUCTURE.');
        objects = buildObjStruct(list_path, list_img, list_event, list_event2);
        save([feat_path '/objects.mat'], 'objects');
    else
        disp('# LOADING OBJECTS FILE...');
        load([feat_path '/objects.mat']);
    end
end

%% Extract W objects (using objectness) for each image
if(reload_objectness && ~do_abstract_concept_discovery)
    disp(['# EXTRACTING ' num2str(objectness.W) ' OBJECTS and objectness per image for all images...']);
    tic %%%%%%%%%%%%%%%%%%%%%%%
    objects = extractObjects(path_folders, objects, prop_res, objectness, format, objectness.workingpath);
    toc %%%%%%%%%%%%%%%%%%%%%%%
    save([feat_path '/objects.mat'], 'objects');
end


%% Load context selection info
if(feature_params.useContext)
    disp('# LOADING CONTEXT INFO...');
    load([feat_path '/superpixels.mat']);
    load([feat_path '/context_selection.mat']);
end

%% Get all indices of all objects in a matrix
all_indices = getAllIndices(objects);

if(has_ground_truth)
    %% Get a certain percentage of objects' true labels
    disp('# INITIAL SAMPLES SELECTION...');
    [objects, classes] = initialSamplesTrueLabels(objects, feature_params, classes, 1, all_indices);

    if(apply_obj_vs_noobj)
        disp('# APPLYING Obj VS NoObj SVM classifier...');
        tic %%%%%%%%%%%%%%%%%%%%%%%
        [objects, nObj, nNoObj] = applyObjVSNoObj(objects, classes, objVSnoobj_params, features_type, V, V_min_norm, V_max_norm, feature_params, feat_path, path_folders, prop_res);
        disp(['Found ' num2str(nObj) ' Objects and ' num2str(nNoObj) ' No Objects.']);
        toc %%%%%%%%%%%%%%%%%%%%%%%
    end
end
addpath(path_svm); % add path OneClass-SVM

%% Load scene features for the first time
if(feature_params.useScene || strcmp(features_type, 'cnn_con'))
    %% Extract features for each object
    if(reload_features_scenes)
        disp('# EXTRACTING FEATURES for each scene...');
        tic %%%%%%%%%%%%%%%%%%%%%%%
        extractFeatures(objects, feature_params, path_folders, prop_res, feat_path, max_size, features_type, [1 0]);
        toc %%%%%%%%%%%%%%%%%%%%%%%
    end
    
    disp('# LOADING SCENE FEATURES...');
    if(strcmp(features_type, 'cnn') || strcmp(features_type, 'cnn_con'))
        [sceneFeatures, ~] = recoverFeatures(objects, 1:length(objects), [], VS, V_min_normS, V_max_normS, [], feature_params, feat_path, false, [], path_folders, prop_res, [2 0 1]);
    elseif(strcmp(features_type, 'original'))
        [sceneFeatures, ~] = recoverFeatures(objects, 1:length(objects), [], VS, V_min_normS, V_max_normS, [], feature_params, feat_path, false, [], path_folders, prop_res, [1 0 1]);
    end   
    %% Get a certain percentage of true labels
    if(feature_params.useScene)
        [objects classes_scenes] = initialSamplesTrueLabels(objects, feature_params, classes_scenes, 2, []);
    end
end


%% Extract features for each object
if(reload_features && (strcmp(features_type, 'original') || strcmp(features_type, 'cnn') || strcmp(features_type, 'cnn_con')))
    disp('# EXTRACTING FEATURES for each object of each image...');
    tic %%%%%%%%%%%%%%%%%%%%%%%
    extractFeatures(objects, feature_params, path_folders, prop_res, feat_path, max_size, features_type, [0 1]);
    toc %%%%%%%%%%%%%%%%%%%%%%%
elseif(strcmp(features_type, 'lshDimReduc'))
    % Load LSH Dim.Reduced features
    disp('# LOADING LSH DIM.REDUCED features...');
    load([feat_path '/featuresLSH.mat']); % features
    load([feat_path '/indicesLSH.mat']); % indices
end

    
%% Iterate for discovering all the object classes until no easy instances available
t = 1; hasEasyObjects = true;
if(do_discovery)
    while(hasEasyObjects && easiness_rate(4) >= t)
        %% Start Scenes labeling
        disp(' ');disp(' ');
        disp('===============================================');
        disp(['        STARTING ITERATION ' num2str(t) ' [SCENES]']);
        disp('===============================================');

        %% Check if still exists some unlabeled scene
        pos_scn = getUnlabeledScenes(objects);

        % Only continue if there is still any unlabeled samples
        if(~isempty(pos_scn))
            %% Get features from scenes
            tic %%%%%%%%%%%%%%%%%%%%%%%
            % Appearance
            appearance_feat = sceneFeatures(pos_scn, :);
            % Object Awareness
            if(feature_params.useObject)
    %             object_feat = recoverObjectFeatures(pos, ...);
            else
                object_feat = [];
            end

            %% Normalize features
            if(t == 1)
                [appearance_feat, minAS, maxAS] = normalize(appearance_feat);
            else
                [appearance_feat] = normalize(appearance_feat, minAS, maxAS);
            end
            [object_feat] = normalizeHistograms(object_feat);
            toc %%%%%%%%%%%%%%%%%%%%%%%

            %% Clustering of easiest samples
            [clusters, best_cluster, silhouetteCoeffs] = clusteringScenes(appearance_feat, object_feat, cluster_scn_params, feature_params);

            %% Label best clusters
            [ objects, classes_scenes, foundLabels ] = automaticLabelingScenes(objects, clusters, cluster_scn_params.nMaxLabelClusters, pos_scn, classes_scenes);


            %% Check labeled instances
            record = checkLabeledInstancesScenes(objects, classes_scenes);
            save(['ExecutionResults/' results_folder '/resultsScenes_' num2str(t) '.mat'], 'record');

        end


        %% Start Objects labeling
        disp(' ');disp(' ');
        disp('===============================================');
        disp(['        STARTING ITERATION ' num2str(t) ' [OBJECTS]']);
        disp('===============================================');

        %% Extract event awareness histograms and scores
        if(feature_params.useEvent)
            disp('# EXTRACTING EVENT AWARENESS...');
            [ histClasses, objects ] = extractEventAwareness( objects, classes, list_event, objectness.W );
        end

        %% Extract scene awareness features and scores
        if(feature_params.useScene)
            disp('# EXTRACTING SCENE AWARENESS...');
            tic %%%%%%%%%%%%%%%%%%%%%%%
            if(feature_params.scene_version == 1)
                if(( t == 1 || ~isempty(pos_scn) ))
                    [ objects ] = extractSceneAwareness( objects, sceneFeatures, feature_params );
                end
            elseif(feature_params.scene_version == 2)
                [ objects ] = extractSceneAwareness2( objects, classes, feature_params );
            else
                error(['Unknown scene version ' num2str(scene_version)]);
            end
            toc %%%%%%%%%%%%%%%%%%%%%%%
        end

        %% Extract context awareness scores
        if(feature_params.useContext)
            disp('# EXTRACTING CONTEXT AWARENESS...');
    %         [ objects ] = extractContextAwareness( objects, superpixels, context_selection, feature_params, feat_path );
            error('Context Awareness not implemented yet!');
        end

        %% Get all scores for all objects, sort them and get only the easiest
        disp('# GETTING EASY OBJECTS...');
        if(do_abstract_concept_discovery)
            [ hasEasyObjects, val, pos_test ] = getEasyObjects( objects, t, objectness.W, easiness_rate, ind_test);
            pos = [];
        else
            [ hasEasyObjects, val, pos ] = getEasyObjects( objects, t, objectness.W, easiness_rate, all_indices);
        end
            
        % Only continue if there is any easy object
        if(hasEasyObjects)

            %% Refilling pool of unlabeled with some labeled samples
            [ val, pos ] = doRefill(val, pos, objects, all_indices, refill, classes);

            %% Get indices from easiest instances
            indices = zeros(length(val), 2); % image and object indices for each selected object
            count = 1;
            if(do_abstract_concept_discovery)
                for p = pos_test
                    indices(count, :) = ind_test(p, :);
                    count = count+1;
                end
            end
            for p = pos
                indices(count, :) = all_indices(p, :);
                count = count+1;
            end

            %% Recover images features of easiest objects
            disp('# RECOVERING FEATURES for easy instances...');
            tic %%%%%%%%%%%%%%%%%%%%%%%
            % ORIGINAL
            if(strcmp(features_type, 'original'))
                [appearance_feat, event_feat] = recoverFeatures(objects, indices, val, V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res, [1 feature_params.useEvent], tests_path);
                if(feature_params.useScene)
                    scene_feat = recoverSceneFeatures(objects, indices, classes_scenes, classes, feature_params);
                else
                    scene_feat = [];
                end
            % CONVOLUTIONAL NEURAL NETWORKS
            elseif(strcmp(features_type, 'cnn') || strcmp(features_type, 'cnn_con'))
                [appearance_feat, event_feat] = recoverFeatures(objects, indices, val, V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res, [2 feature_params.useEvent], tests_path);
                if(feature_params.useScene)
                    scene_feat = recoverSceneFeatures(objects, indices, classes_scenes, classes, feature_params);
                else
                    scene_feat = [];
                end
                % CNN object candidate + CNN scene
                if(strcmp(features_type, 'cnn_con'))
                    [appearance_feat] = concatenateCNN(appearance_feat, sceneFeatures, indices);
                end
            % LSH DIM. REDUCED
            elseif(strcmp(features_type, 'lshDimReduc')) 
                % Appearance
                appearance_feat = features(pos, :);
                % Event Awareness
                [~, event_feat] = recoverFeatures(objects, indices, val, V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res, [0 feature_params.useEvent], tests_path);
                % Scene Awareness
                if(feature_params.useScene)
                    scene_feat = recoverSceneFeatures(objects, indices, classes_scenes, classes, feature_params);
                else
                    scene_feat = [];
                end
            end

            %% Normalize features
            if(t == 1)
                [appearance_feat, minAO, maxAO] = normalize(appearance_feat);
            else
                [appearance_feat] = normalize(appearance_feat, minAO, maxAO);
            end
            [event_feat, minEO, maxEO] = normalize(event_feat);
            toc %%%%%%%%%%%%%%%%%%%%%%%

            %% PCA representation
            if(show_PCA)
                disp('# SHOWING PCA REPRESENTATION of the data...');
                showPCA(appearance_feat, feature_params, objects, indices, tests_path, cluster_params.clusName);
            end

            %% PCA dimensionality reduction
            if(feature_params.usePCA)
                disp('# APPLYING PCA...');
                tic %%%%%%%%%%%%%%%%%%%%%%%
                appearance_feat = applyPCA(appearance_feat, feature_params);
                disp(['Got ' num2str(size(appearance_feat,2)) ' dimensions covering ' num2str(feature_params.minVarPCA*100) '% of variance.']);
                toc %%%%%%%%%%%%%%%%%%%%%%%
            end

            %% Clustering of easiest samples
            [clusters, best_cluster, silhouetteCoeffs] = clustering(appearance_feat, event_feat, scene_feat, cluster_params, feature_params, objects, indices);

            %% Evaluate clustering
            if(eval_clustering)
                disp('# EVALUATING CLUSTERING RESULTS...');
                evalResults = evaluateClustering( objects, indices, clusters, cluster_params );
            else
                evalResults = [];
            end

            %% Shows clustering result
            if(show_clustering)
                disp('# STORING CLUSTERING RESULTS...');
                showClustering( objects, path_folders, prop_res, indices, clusters, cluster_params, cluster_params.clustering_type{1}, silhouetteCoeffs, evalResults, t, tests_path )
            end

            if(has_ground_truth || do_abstract_concept_discovery)
                %% Label best clusters
                [ objects, classes, foundLabels, Nlabeled_clus ] = automaticLabeling(objects, clusters, cluster_params, indices, classes, t, do_abstract_concept_discovery);
            else
                %% TODO: Manually label!
            end

            %% Build OneClass SVM for each label of the newly labeled samples
            disp('# BUILDING OneClass SVMs...');
            models = buildOneClassSVM( appearance_feat, foundLabels, svmParameters );

            %% Classify Harder Instances
            disp('# CLASSIFYING HARDER INSTANCES...');
            objects = classifyHarderInstances( objects, appearance_feat, foundLabels, indices, models, classes, show_harderInstances, prop_res, path_folders, t, tests_path );

            %% Change clustering criteria if all the following conditions are accomplished:
            %       - do_abstract_concept_discovery
            %       - we have less than easiness_rate(3) samples left
            %       - Nlabeled_clus < cluster_params.nMaxLabelClusters
            if(do_abstract_concept_discovery && size(pos_test,1) < easiness_rate(3) && Nlabeled_clus < cluster_params.nMaxLabelClusters)
                cluster_params.wardStdTimes = cluster_params.wardStdTimes*0.2;
            end
        end

        %% Check labeled instances
        if(has_ground_truth)
	    record = checkLabeledInstances(objects, classes);
            save([results_folder '/resultsObjects_' num2str(t) '.mat'], 'record');
	end

        %% Increment iteration
        t = t+1;

    end
    
    %% Save final results
    disp(' ');
    disp('# DISCOVERY FINISHED!');
    save([results_folder '/objects_results.mat'], 'objects');
    save([results_folder '/classes_results.mat'], 'classes');
    save([results_folder '/classes_scenes_results.mat'], 'classes_scenes');
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   START FINAL EVALUATION  SVM/KNN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(has_ground_truth && do_final_evaluation) % only if has ground truth
    
    disp(' ');
    disp('# RESULTS EVALUATION STARTING!');
    %% Retrieve train/test final samples information
    [trainX_ind, trainY_true, ~, testX_ind, testY] = getFinalTestsSamples(objects, classes);


    %% Get training samples
    disp('# RECOVERING APPEARANCE FEATURES for TRAINING instances...');
    tic %%%%%%%%%%%%%%%%%%%%%%%
    % ORIGINAL
    if(strcmp(features_type, 'original'))
        [trainX, ~] = recoverFeatures(objects, trainX_ind, 1:size(trainX_ind,1), V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, false, t+1, path_folders, prop_res, [1 0]);
    % CONVOLUTIONAL NEURAL NETWORKS
    elseif(strcmp(features_type, 'cnn'))
        [trainX, ~] = recoverFeatures(objects, trainX_ind, 1:size(trainX_ind,1), V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, false, t+1, path_folders, prop_res, [2 0]);
    % LSH DIM. REDUCED
    elseif(strcmp(features_type, 'lshDimReduc')) 
        error(['Features type ' features_type ' not supported!']);
    end
    toc %%%%%%%%%%%%%%%%%%%%%%%

    % Normalize
    [trainX, minX, maxX] = normalize(trainX);


    %% Apply clustering on training samples
    feature_params.useScene = false;
    feature_params.useEvent = false;
    feature_params.useContext = false;
    feature_params.useObject = false;
    [clusters, ~, ~] = clustering(trainX, [], [], cluster_params, feature_params, objects, []);

    %% Label all clusters found (majority voting)
    [ objects, classes, foundLabels ] = automaticLabeling(objects, clusters, Inf, trainX_ind, classes);
    trainY = formatTrainY(foundLabels, trainX_ind);


    %% Train Final models
    disp('# TRAINING FINAL CLASSIFIERS...');
    tic %%%%%%%%%%%%%%%%%%%%%%%
    disp('Building clusters SVM (1/4).');
    modelSVMclusters = trainSVM(trainX, trainY, final_params);
    disp('Building clusters KNN (2/4).');
    modelKNNclusters = trainKNN(trainX, trainY, final_params);
    disp('Building true SVM (3/4).');
    modelSVMtrue = trainSVM(trainX, trainY_true, final_params);
    disp('Building true KNN (4/4).');
    modelKNNtrue = trainKNN(trainX, trainY_true, final_params);
    toc %%%%%%%%%%%%%%%%%%%%%%%
    clear trainX;


    %% Get test samples
    disp('# RECOVERING APPEARANCE FEATURES for TEST instances...');
    tic %%%%%%%%%%%%%%%%%%%%%%%
    % ORIGINAL
    if(strcmp(features_type, 'original'))
        [testX, ~] = recoverFeatures(objects, testX_ind, 1:size(testX_ind,1), V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, false, t+1, path_folders, prop_res, [1 0]);
    % CONVOLUTIONAL NEURAL NETWORKS
    elseif(strcmp(features_type, 'cnn'))
        [testX, ~] = recoverFeatures(objects, testX_ind, 1:size(testX_ind,1), V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, false, t+1, path_folders, prop_res, [2 0]);
    % LSH DIM. REDUCED
    elseif(strcmp(features_type, 'lshDimReduc')) 
        error(['Features type ' features_type ' not supported!']);
    end
    toc %%%%%%%%%%%%%%%%%%%%%%%

    % Normalize
    [testX] = normalize(testX, minX, maxX);


    %% Test Final models
    disp('# TESTING FINAL CLASSIFIERS...');
    tic %%%%%%%%%%%%%%%%%%%%%%%
    disp('Testing clusters SVM (1/4).');
    result_SVM_clus = testSVM(testX, testY, modelSVMclusters);
    disp('Testing clusters KNN (2/4).');
    result_KNN_clus = testKNN(testX, testY, modelKNNclusters);
    disp('Testing true SVM (3/4).');
    result_SVM_true = testSVM(testX, testY, modelSVMtrue);
    disp('Testing true KNN (4/4).');
    result_KNN_true = testKNN(testX, testY, modelKNNtrue);
    toc %%%%%%%%%%%%%%%%%%%%%%%


    %% Save final results
    save([results_folder '/result_SVM_clus.mat'], 'result_SVM_clus');
    save([results_folder '/result_KNN_clus.mat'], 'result_KNN_clus');
    save([results_folder '/result_SVM_true.mat'], 'result_SVM_true');
    save([results_folder '/result_KNN_true.mat'], 'result_KNN_true');
end


%% Test Execution Finished!
disp('# TEST EXECUTION FINISHED!!!');
sendEmail('Test Finished', ['Test results stored in folder ' results_folder '.']);

% exit;
