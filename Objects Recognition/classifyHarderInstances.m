function [ objects ] = classifyHarderInstances( objects, appearance_feat, foundLabels, indices, models, classes, show_harderInstances, prop_res, path_folders, t, tests_path )
%CLASSIFYHARDERINSTANCES Uses the built OneClass SVMs in "models" for
% trying to classify the unlabeled instances in "indices".

    nModels = length(models);
    nSamples = size(indices,1);

    %% Get labeled indices
    L = [];
    for i = 1:nModels
        L = [L; foundLabels{models(i).labelId}];
    end

    %% Get unlabeled indices
    U = setdiff(1:nSamples, L);
    
    %% Apply each SVM
    if(~isempty(U))
        
        if(show_harderInstances)
            top_dir = [tests_path '/Clusters Results/Harder Instances_iter' num2str(t)];
            mkdir(top_dir);
        end
        
        for i = 1:nModels
            
            if(show_harderInstances)
                dir_name = [top_dir '/' num2str(i) '_' classes(models(i).labelId+1).name];
                mkdir(dir_name);
                mkdir([dir_name '/Cluster_Samples']);
                mkdir([dir_name '/Hard_Samples']);
                
                prev_labeled = foundLabels{models(i).labelId};
                count_ = 1;
                for el = prev_labeled'
                    ind = indices(el,:);
                    i_samp = ind(1); j_samp = ind(2);
                    
                    obj = objects(i_samp).objects(j_samp);
                    img = objects(i_samp);
                    
                    obj_img = imread([path_folders '/' img.folder '/' img.imgName]); % WINDOWS Y MAC
                    obj_img = imresize(obj_img,[size(obj_img,1)/prop_res size(obj_img,2)/prop_res]);
                    obj_img = obj_img(obj.ULy:obj.BRy, obj.ULx:obj.BRx, :);
                    
                    imwrite(obj_img, [dir_name '/Cluster_Samples' '/' img.folder(1:8) '_' img.imgName '_' num2str(count_) '.jpg']);
                    count_ = count_+1;
                end
                
            end
            
            features = appearance_feat(U,:);
            predicted_label = svmpredict(ones(length(U), 1), features, models(i).model, '-q');
            newSamples = U(predicted_label==1);
            %% Store new samples' labels
            count_ = 0;
            for s = newSamples
                ind = indices(s,:);
                % Label if not belongs to the initial selection
                if(isempty(objects(ind(1)).objects(ind(2)).initialSelection))
                    objects(ind(1)).objects(ind(2)).label = models(i).labelId;
                end
                
                if(show_harderInstances)
                    i_samp = ind(1); j_samp = ind(2);
                    
                    obj = objects(i_samp).objects(j_samp);
                    img = objects(i_samp);
                    
                    obj_img = imread([path_folders '/' img.folder '/' img.imgName]); % WINDOWS Y MAC
                    obj_img = imresize(obj_img,[size(obj_img,1)/prop_res size(obj_img,2)/prop_res]);
                    obj_img = obj_img(obj.ULy:obj.BRy, obj.ULx:obj.BRx, :);
                    
                    imwrite(obj_img, [dir_name '/Hard_Samples' '/' img.folder(1:8) '_' img.imgName '_' num2str(count_) '.jpg']);
                end
                count_ = count_+1;
            end
            %% Update labeled and unlabeled indices
            L = [L; newSamples'];
            U = setdiff(1:nSamples, L);

            disp(['Classified ' num2str(length(newSamples)) ' new hard sample/s of class ' classes(models(i).labelId+1).name '.']);
        end
    end
end

