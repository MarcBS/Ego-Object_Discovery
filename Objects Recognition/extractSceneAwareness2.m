function [ objects ] = extractSceneAwareness2( objects, classes, feature_params )
%EXTRACTSCENEAWARENESS2 Extracts scene awareness related to the objects
%appearing.

    lenImgs = size(objects,2);

    %% Extract scene awareness (shared over all the objects in the same image)
    % we get all the objects detected in each scene/image
    for i = 1:lenImgs % for each image
        histClasses = zeros(1, length(classes)-1);
        nObjects = length(objects(i).objects);
        for j = 1:nObjects % for each window
            % Increment number of objects found for each class and
            % each scene.
            lab = objects(i).objects(j).label;
            if(lab > 0) % if labeled only
                histClasses(lab) = histClasses(lab) + 1;
            end
        end
        % Store score
        objects(i).sceneAwareScore = sum(histClasses)/nObjects;
        % Normalize histogram
        histClasses = normalizeHistograms(histClasses);
        % Store histograms
        objects(i).sceneAwareFeatures = histClasses;
    end

end

