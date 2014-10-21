function [ allFeat ] = concatenateCNN( appearance_feat, sceneFeatures, indices )
%CONCATENATECNN Concatenates the features from each object with the general
% features of the scene where the object belongs to.

    allFeat = zeros(size(appearance_feat,1), size(appearance_feat,2)+size(sceneFeatures,2));
    
    count = 1;
    for ind = indices'
        allFeat(count, :) = [appearance_feat(count, :) sceneFeatures(ind(1), :)];
        count = count+1;
    end

end

