function [ objects, classes, found_labels, labeled_clus ] = automaticLabeling(objects, clusters, cluster_params, indices, classes, t, do_abstract_concept_discovery)
%AUTOMATICLABELING Automatically labels the first "nMaxLabelClusters"
%clusters assigning them the majority label.
    
    nMaxLabelClusters = cluster_params.nMaxLabelClusters;
    % only used for abstract concept discovery
    % (do_abstract_concept_discovery == true)
    minPerPurityConcept = cluster_params.minPerPurityConcept;

    % Newly labeled samples indexed by their label
    found_labels = {};
    
    % Label names of newly labeled samples
    found_names = '';
    % Number of labeled clusters
    labeled_clus = 0;

    nClus = length(clusters);
    nClus = min(nClus, nMaxLabelClusters); % truncate to nMaxLabelClusters if more
    
    labNames = {};
    for i = 1:length(classes)
        labNames{i} = classes(i).name;
    end
    
    %% Evaluate on each cluster
    result = {};
    for i = 1:nClus
        clus = clusters{i};
        labels = {};
        %% For each element in the cluster
        count_el = 1;
        for el = clus
            ind = indices(el, :);
            k = ind(1); j = ind(2);
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
                    % Store {majorityLabel, allLabels, #majority}
                    majorityLabel = un_labels(p(1));
                    result{i} = {majorityLabel{1}, labels, v(1)};
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
                end
                try
                    found_labels{labelId} = [found_labels{labelId}; el];
                catch
                    found_labels{labelId} = [el];
                end
            end
        end
    end

    %% Show how many clusters have been labeled
    disp(['Labeled ' num2str(labeled_clus) ' clusters:' found_names]);
end

