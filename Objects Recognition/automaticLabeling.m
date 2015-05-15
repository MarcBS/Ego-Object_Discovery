function [ objects, classes, found_labels, labeled_clus ] = automaticLabeling(objects, clusters, features, cluster_params, indices, classes, t, do_abstract_concept_discovery, feature_params, feat_path, path_folders, prop_res)
%AUTOMATICLABELING Automatically labels the first "nMaxLabelClusters"
%clusters assigning them the majority label.
    
    nMaxLabelClusters = cluster_params.nMaxLabelClusters;
    % only used for abstract concept discovery
    % (do_abstract_concept_discovery == true)
    minPerPurityConcept = cluster_params.minPerPurityConcept;
    minSimilarityRefillConcept = cluster_params.minSimilarityRefillConcept;
    minSimilarityRefillConcept_value = cluster_params.minSimilarityRefillConcept_value;
    
    if(minSimilarityRefillConcept)
        clusters_means = [];
    end

    % Newly labeled samples indexed by their label
    found_labels = {};
    
    % Label names of newly labeled samples
    found_names = '';
    % Number of labeled clusters
    labeled_clus = 0;

    nClus = length(clusters);
%     nClus = min(nClus, nMaxLabelClusters); % truncate to nMaxLabelClusters if more
    
    labNames = {};
    for i = 1:length(classes)
        labNames{i} = classes(i).name;
    end
    
    %% Evaluate on each cluster
    result = {};
    i = 1;
    while(i <= nClus && labeled_clus < nMaxLabelClusters)
        clus = clusters{i};
        labels = {};
        %% For each element in the cluster
        count_el = 1;
        this_ind = [];
        for el = clus
            ind = indices(el, :);
            k = ind(1); j = ind(2);
            this_ind = [this_ind; k j];
            obj = objects(k).objects(j);
            if(do_abstract_concept_discovery)
                if(~isempty(obj.label) && obj.label ~= 0)
                    labels{count_el} = classes(obj.label+1).name; % insert abstract concept label in list
                    count_el = count_el +1;
                end
            else
                labels{count_el} = obj.trueLabel; % insert label in list
                count_el = count_el +1;
            end
        end
        % Store cluster mean
        if(minSimilarityRefillConcept)
            clusters_means(i,:) = classMean( this_ind, features, indices );
        end
        %% Store majorityVoting result
        % Get majority label
        un_labels = unique(labels);
        n = zeros(length(un_labels), 1);
        for iy = 1:length(un_labels)
          n(iy) = sum(strcmp(un_labels{iy}, labels));
        end
        [v, p] = sort(n, 'descend');
        
        if(do_abstract_concept_discovery)
            % The current cluster does not have any refilled sample, we
            % must create a new concept
            if(isempty(v))
                new_concept = sprintf('concept_%0.4d', length(classes)-2+1);
                result{i} = {new_concept, {}, 0};
            else
                % We must hava a minimum percentage of samples from the
                % majority label
                if(v(1)/sum(v) >= minPerPurityConcept)
                    
                    check = true;
                    if(minSimilarityRefillConcept)
                        lab = un_labels(p(1)); lab = lab{1};
                        labelId = find(ismember(labNames,lab));
                        dist = pdist([clusters_means(i,:); classes(labelId).mean]);
                        if(dist >= minSimilarityRefillConcept_value)
                            check = false;
                        end
                    end
                    
                    if(check)
                        % Store {majorityLabel, allLabels, #majority}
                        majorityLabel = un_labels(p(1));
                        result{i} = {majorityLabel{1}, labels, v(1)};
                    else
                        result{i} = {[], {}, 0};
                    end
                % If we do not have more than minPerPurityConcept, then we
                % do not label the cluster
                else
                    result{i} = {[], {}, 0};
                end
            end
        else
            % Store {majorityLabel, allLabels, #majority}
            majorityLabel = un_labels(p(1));
            result{i} = {majorityLabel{1}, labels, v(1)};
        end
        result{i}{4} = length(clus);
        
        %% Store resulting labels
        labelName = result{i}{1};
        if(~isempty(labelName))
            labeled_clus = labeled_clus+1;
            found_names = [found_names ' "' labelName ' (MajorityLabel:' num2str(result{i}{3}) ' | Total:' num2str(result{i}{4}) ')"'];
            labelId = find(ismember(labNames,labelName));
            % New Label
            if(isempty(labelId))
                labelId = length(classes);
                classes(labelId+1).name = labelName;
                classes(labelId+1).label = labelId;
                classes(labelId+1).indices = [];
                labNames{labelId+1} = labelName;
            % Previously introduced Label
            else
                labelId = classes(labelId).label;
            end

            %% Insert label id to all samples in i-th cluster
            clus = clusters{i};
            for el = clus
                ind = indices(el, :);
                k = ind(1); j = ind(2);
                % Only change label if it is not part of the initialSelection
                % (see doRefill.m)
                if(isempty(objects(k).objects(j).initialSelection))
                    objects(k).objects(j).label = labelId;
                    objects(k).objects(j).iteration = t;
                    objects(k).objects(j).iterationCluster = i;
                    classes(labelId+1).indices = [classes(labelId+1).indices; [k j]];
                end
                try
                    found_labels{labelId} = [found_labels{labelId}; el];
                catch
                    found_labels{labelId} = [el];
                end
            end
            
            %% Recalculate class mean
            if(minSimilarityRefillConcept)
                disp('## Recovering features to recalculate class mean...');
                [this_feat, ~] = recoverFeatures(objects, classes(labelId+1).indices, ones(1,size(classes(labelId+1).indices,1)), NaN, NaN, NaN, NaN, feature_params, feat_path, false, 0, path_folders, prop_res, [2 0], NaN);
                this_feat = normalize(this_feat);
                
                classes(labelId+1).mean = classMean(classes(labelId+1).indices, this_feat, classes(labelId+1).indices);
            end
        end
    	i = i+1;
    end

    %% Show how many clusters have been labeled
    disp(['Labeled ' num2str(labeled_clus) ' clusters:' found_names]);
end

