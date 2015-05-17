function [ mean ] = classMean( indices, features, feat_indices )
%CLUSTERMEAN Calculates the mean of the set of samples from the same class.

    sumFeatures = zeros(1,size(features,2));

    nIndices = size(indices,1);
    for i = 1:nIndices
        pos = find(ismember(feat_indices,indices(i,:),'rows'));
        if(isempty(pos))
            error('Element not found in features indices.');
        else
            sumFeatures = sumFeatures + features(pos,:);
        end
    end

    mean = sumFeatures/nIndices;
    
end

