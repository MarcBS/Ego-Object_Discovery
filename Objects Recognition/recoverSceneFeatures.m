function [ scene_feat ] = recoverSceneFeatures( objects, indices, classes_scenes, classes, feature_params )
%RECOVERSCENEFEATURES Gets the scene features for each object candidate
% from the list of scene features of each complete image.

    % Prepare matrix
    if(feature_params.scene_version == 1)
        scene_feat = zeros(size(indices,1), length(classes_scenes));
    elseif(feature_params.scene_version == 2)
%         scene_feat = zeros(size(indices,1), length(classes));
        scene_feat = zeros(size(indices,1), length(classes)-1);
    end

    % Insert features from all elements
    count = 1;
    for ind = indices(:,1)'
        if(feature_params.scene_version == 1)
            scene_feat(count, :) = objects(ind).sceneAwareFeatures;
        elseif(feature_params.scene_version == 2)
%             if(isempty(objects(ind).labelSceneRuntime))
%                 lab = -1;
%             else
%                 lab = isempty(objects(ind).labelSceneRuntime);
%             end
%             scene_feat(count, :) = [lab objects(ind).sceneAwareFeatures];
            scene_feat(count, :) = objects(ind).sceneAwareFeatures;
        end
        count = count+1;
    end

end

