function [ appearance_feat, event_feat ] = recoverFeatures( objects, indices, val, V, min_norm, max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res )
%RECOVERFEATURES Prepares all the kinds of features for the chosen samples
% in indices.

    %% If show images we create a folder to store them
    if(show_easiest)
        mkdir(['Easiest_Objects_t=' num2str(t)]);
    end

    %% Prepare features
    bHOG = feature_params.bHOG;
    lHOG = feature_params.lHOG;
    M = feature_params.M;
    L = feature_params.L;
    bLAB = feature_params.bLAB;

    %%% Prepare matrices of features %%%
    lenPHOG = 0; for i = 0:lHOG; lenPHOG = lenPHOG + 4^i * bHOG; end % calculate len of Pyramid-HOG
    lenSPM = uint16(M * (1/3)*(4^(L+1) - 1)); % calculate len of Spatial Pyramid Matchings
    appearance_feat = zeros(size(indices,1), bLAB*3 + lenPHOG + lenSPM); % appearance features A(x)
    event_feat = zeros(size(indices,1), 1 + size(histClasses,2)); % event features C(x). 1 for event label and rest for event awareness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    count = 1;
    for ind = indices'
        i = ind(1); % image idx
        j = ind(2); % object idx
        obj = objects(i).objects(j);
        img = objects(i);
        score = val(count);
        
        % Load features
        % tmp line (SenseCam Short), delete after tests!!!
        % load([feat_path '/Images/img' num2str(i+1590) '/obj' num2str(j) '.mat']); % obj_feat
        load([feat_path '/img' num2str(i) '/obj' num2str(j) '.mat']); % obj_feat
        
        %% Appearance Descriptors A(x)
        appearance_feat(count, 1:bLAB*3) = obj_feat.LAB_feat;
        appearance_feat(count, bLAB*3+1:bLAB*3+lenPHOG) = obj_feat.PHOG_feat;
        appearance_feat(count, bLAB*3+lenPHOG+1:end) = spatialPyramidMatching(obj_feat.SIFT_feat, V, min_norm, max_norm, L);
        
        %% Event Descriptors E(x)
        if(~isempty(histClasses))
            event_feat(count, 1) = objects(i).labelEvent;
            event_feat(count,2:end) = histClasses(objects(i).idEvent, :);
        end
        
        %% Show in a folder if we want to
        if(show_easiest)
            % Get square of the object
%             obj_img = imread([path_folders '/Datasets/' img.folder '/' img.imgName]); % LINUX
            obj_img = imread([path_folders '/' img.folder '/' img.imgName]); % WINDOWS Y MAC
            obj_img = imresize(obj_img,[size(obj_img,1)/prop_res size(obj_img,2)/prop_res]);
            obj_img = obj_img(obj.ULy:obj.BRy, obj.ULx:obj.BRx, :);
            imwrite(obj_img, ['Easiest_Objects_t=' num2str(t) '/' img.folder(1:8) '_' num2str(j) '_' img.imgName '_score=' num2str(score) '.jpg']);
        end
        
        count = count+1;
        
        if(mod(count,100) == 0 || size(indices,1) == count)
            disp(['Features extracted from ' num2str(count) '/' num2str(size(indices,1)) ' objects.']);
        end
        
    end

end

