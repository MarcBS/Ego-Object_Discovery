function [ models ] = buildOneClassSVM( appearance_feat, foundLabels, svmParameters )
%BUILDONECLASSSVM Builds and returns a OneClass SVM for each of the different 
%labels corresponding to the samples indixed by foundLabels.

    lenFound = length(foundLabels);
    models = [];
    
    countModels = 1;
    for i = 2:lenFound % don't pick neither 0 (not analyzed) nor 1 (no object)
        %% For each label in foundLabels
        if(~isempty(foundLabels{i}))
            %% Store the label of this class
            models(countModels).labelId = i;
            
            %% Retrieve all the features for this samples
            this_samples = foundLabels{i};
            nSamples = length(this_samples);
            features = zeros(nSamples, size(appearance_feat,2));
            for j = 1:nSamples
                ind = this_samples(j);
                features(j,:) = appearance_feat(ind, :);
            end
            
            %% Build OneClass SVM
            models(countModels).model = svmtrain(ones(nSamples,1), features, svmParameters);
            
            countModels = countModels+1;
        end
    end

    if(isempty(models))
        disp('No classes different from "No Object" found.');
    end
    
end

