function [ objects ] = extractSceneAwareness(  objects, sceneFeatures, feature_params )
%EXTRACTSCENEAWARENESS Extracts the Scene Awareness scores from all the
%objects.

    % Avoid divisions by 0
    sceneFeatures(sceneFeatures==0) = 1e-10;
    
    maxSamples = feature_params.maxSceneAwarenessSamples;

    %% Get labels from each sample (0 = unlabeled)
    lenScenes = length(objects);
    labels = zeros(1, lenScenes);
    for i = 1:lenScenes
        if(~isempty(objects(i).labelSceneRuntime))
            labels(i) = objects(i).labelSceneRuntime;
        end
    end
    
    %% Get indices of already labeled samples for building the exemplar-based models
    allLabels = unique(labels); allLabels = allLabels(allLabels~=0);
    ind_labeled = {};
    for l = allLabels
        this_ind = find(labels==l);
        if(length(this_ind) > maxSamples)
            this_ind = randsample(this_ind, maxSamples);
        end
        ind_labeled{l} = this_ind;
    end
    
    
    %% Get the Scene Aware Score for each sample (even if it is already labeled) and store it into "objects"
    count = 1;
    for ind = 1:lenScenes
%         tic
        this_scores = zeros(1, length(allLabels));
        U = sceneFeatures(ind, :); % features for current instance
        %% Iterate over each possible already found label
        for l = allLabels
            L = sceneFeatures(ind_labeled{l}, :); % features for labeled instances
            this_scores(l) = exemplarBasedModel(U, L);
        end
        % Scene Aware Score
        objects(ind).sceneAwareScore = max(this_scores);
        % Scene Aware Features
        objects(ind).sceneAwareFeatures = normalizeHistograms(this_scores);
        % Keep the counting of the already extracted information
%         if(mod(count, 100) == 0 || count == lenScenes)
%             disp(['Scene awareness calculated for ' num2str(count) '/' num2str(lenScenes)]);
%         end
        count = count+1;
%         toc
    end
    
end

