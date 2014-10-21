function [ objects, classes ] = initialSamplesTrueLabels( objects, feature_params, classes, type, indices )
%INITIAL Stores a certain initial percentage of samples as already labeled.
%
%   type: indicates the type of samples that we are labeling,
%       type == 1 --> objects
%       type == 2 --> scenes
%   indices: indices to all objects (only used when type == 1)
%
%%%

    %% Randomly selects the samples to store
    if(type == 1)
        lenObjects = size(indices,1);
        nGetObjects = round(lenObjects * feature_params.initialObjectsPercentage);
        toStore = randsample(1:lenObjects, nGetObjects);
    elseif(type == 2)
        lenScenes = length(objects);
        nGetScenes = round(lenScenes * feature_params.initialScenesPercentage);
        toStore = randsample(1:lenScenes, nGetScenes);
    end
    
    %% For each selected object sample
    if(type == 1)
        nImages = length(objects);
        % Initialize initialSelection filed in objects structure
        for i = 1:nImages
            objects(i).objects(1).initialSelection = [];
        end
        for i = toStore
            this_label = objects(indices(i,1)).objects(indices(i,2)).trueLabel;
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
            objects(indices(i,1)).objects(indices(i,2)).label = id;
            % Stores a flag to indicate that it has been initially labeled
            objects(indices(i,1)).objects(indices(i,2)).initialSelection = true;
        end
        
    %% For each selected scene sample
    elseif(type == 2)
        for i = toStore
            this_label = objects(i).labelScene;
            found = false;
            % Look for its labelID in the list of labels
            for j = 1:length(classes)
                if(strcmp(classes(j).name, this_label))
                    num = j;
                    found = true;
                end
            end
            % Store its id as already labeled (only for this execution)
            if(~found)
                classes(length(classes)+1).name = this_label;
                num = length(classes);
            end
            % Stores the label
            objects(i).labelSceneRuntime = num;
            % Stores a flag to indicate that it has been initially labeled
            objects(i).initialSelection = true;
        end

        %% If no sample selected, then initialize to empty array
        if(isempty(toStore))
            objects(1).labelSceneRuntime = [];
        end
    end
        
end

