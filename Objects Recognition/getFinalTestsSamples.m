function [ trainX_ind, trainY_true, trainY, testX_ind, testY ] = getFinalTestsSamples( objects, classes )
%GETFINALTESTSSAMPLES Retrieves the samples for the final tests splitted
%into training and test sets.

    %% Format classes names
    classes_names = {};
    for i = 1:length(classes)
        classes_names = {classes_names{:}, classes(i).name};
    end
    
    %% Prepare train/test samples information
    %%% Initial samples (test samples), common for any method
    testX_ind = [];
    testY = [];
    %%% Labeled during execution samples (train samples)
    trainX_ind = [];
    trainY_true = []; % true labels
    trainY = []; % assigned labels during execution

    %% Find train/test samples
    for i = 1:length(objects)
        for j = 1:length(objects(i).objects)
            if(objects(i).objects(j).initialSelection)
                testX_ind = [testX_ind; i j];
                testY = [testY; objects(i).objects(j).label];
            else % if not initially labeled
                if(objects(i).objects(j).label ~= 0) % if labeled during execution
                    trainX_ind = [trainX_ind; i j];
                    trainY = [trainY; objects(i).objects(j).label];
                    id = find(ismember(classes_names, objects(i).objects(j).trueLabel));
                    trainY_true = [trainY_true; id-1];
                end
            end
        end
    end

end

