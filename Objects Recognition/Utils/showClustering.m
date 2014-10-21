function showClustering( objects, path_folders, prop_res, indices, clusters, cluster_params, method, silhouetteCoeffs, evalResults, t, tests_path )
%SHOWCLUSTERING Shows clustering results.
%   Stores the objects that have fallen in different clusters also in
%   different folders for checking the differences.
%
%   indices = [i j] (i = image, j = object in image) for all the "easy" objects.
%   clusters = cell with the position in the indices array for each
%       specific element in each cluster.
%   clus_name = name assigned to the current clustering produced.
%   method = {'lsh', 'clink'}, type of clustering used.
%   silhouetteCoeffs = "score" for each cluster (only calculated with
%       'clink').
%   evalResults = results obtained from evaluation (if evaluated).
%%%%

    clus_name = cluster_params.clusName;
    clus_mode = cluster_params.clusShowMode;
    
    % Define clusters about to show w.r.t. show mode
    nClus = length(clusters);
    if(strcmp(clus_mode, 'all'))
        indices_clus = 1:nClus;
    elseif(strcmp(clus_mode, 'best&worse'))
        nShow = min(8,nClus);
        top = round(nShow/2);
        if(top*2 > nShow)
            bottom = top-1;
        else
            bottom = top;
        end
        indices_clus = [1:top (nClus-bottom+1):nClus];
    end
    

    % Creates the folder for this specific clustering result
    count = 1;
    clus_fold = [tests_path '/Clusters Results/' 'Clustering_Objects_' method '_' clus_name '_iter' num2str(t)];
    mkdir(clus_fold);
    %% For each cluster obtained
    for c = clusters
        
        if(sum(indices_clus == count) == 1)
        
            % Creates the folder for this specific cluster
            % if(strcmp(method, 'clink'))
            %     this_dir = [clus_fold '/cluster_' num2str(count) '_silcoeff=' num2str(silhouetteCoeffs(count))];
            % else
            %     this_dir = [clus_fold '/cluster_' num2str(count)];
            % end
            if(~isempty(silhouetteCoeffs))
                this_dir = [clus_fold '/cluster_' num2str(count) '_silcoeff=' num2str(silhouetteCoeffs(count))];
            else
                this_dir = [clus_fold '/cluster_' num2str(count)];
            end
            mkdir(this_dir);

            % Gets the distinctive indices for the cluster objects
            count_el = 1;
            c = c{1};
            idx_c = zeros(length(c),2);

            %% For each object in cluster
            for el = c
                % Get indices
                idx = indices(el,:); i = idx(1); j = idx(2);
                idx_c(count_el, :) = indices(el, :);

                % Get image and object in image
                obj = objects(i).objects(j);
                img = objects(i);

                % Extract object patch from image
                obj_img = imread([path_folders '/' img.folder '/' img.imgName]); % WINDOWS Y MAC
                obj_img = imresize(obj_img,[size(obj_img,1)/prop_res size(obj_img,2)/prop_res]);
                obj_img = obj_img(obj.ULy:obj.BRy, obj.ULx:obj.BRx, :);

                % Store it in the corresponding folder
                if(isempty(evalResults))
                    imwrite(obj_img, [this_dir '/' img.folder(1:8) '_' img.imgName '_' num2str(j) '.jpg']);
                else
                    name = regexp(img.imgName(3:end), '\.', 'split');
                    imwrite(obj_img, [this_dir '/' img.folder(1:8) '_' name{1} '_' num2str(j) '_' evalResults{1}{count}{2}{count_el} '.jpg']);
                end

                % Show progress
                if(count_el == length(c)) 
                    disp(['Clusters ' num2str(count) '/' num2str(length(clusters)) ', imgs ' num2str(count_el) '/' num2str(length(c)) ' stored.']);
                end

                count_el = count_el+1;
            end
            %% Store indices
            save([this_dir '/indices.mat'], 'idx_c');
            
        end
        
        count = count+1;
    end

    %% Store results evaluation
    if(~isempty(evalResults))
        save([clus_fold '/evalResults.mat'], 'evalResults');
    end
end

