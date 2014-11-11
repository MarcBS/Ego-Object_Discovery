function [ objects, classes, found_labels ] = automaticLabeling(objects, clusters, nMaxLabelClusters, indices, classes, t)
%AUTOMATICLABELING Automatically labels the first "nMaxLabelClusters"
%clusters assigning them the majority label.
    
    % Newly labeled samples indexed by their label
    found_labels = {};
    
    % Label names of newly labeled samples
    found_names = '';

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
%             if(~strcmp(obj.trueLabel,'No Object') || consider_NoObject)
            labels{count_el} = obj.trueLabel; % insert label in list
            count_el = count_el +1;
%             end
        end
        %% Store majorityVoting result
        % Get majority label
        un_labels = unique(labels);
        n = zeros(length(un_labels), 1);
        for iy = 1:length(un_labels)
          n(iy) = length(find(strcmp(un_labels{iy}, labels)));
        end
%             if(~isempty(n)) % if any sample that isn't No Object
        [v, p] = sort(n, 'descend');
        % Store {majorityLabel, allLabels, #majority}
        majorityLabel = un_labels(p(1));
        result{i} = {majorityLabel{1}, labels, v(1)};
%             end
    end
    
    %% Store resulting labels
    for i = 1:nClus
        labelName = result{i}{1};
        found_names = [found_names ' "' labelName '"'];
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

    %% Show how many clusters have been labeled
    disp(['Labeled ' num2str(nClus) ' clusters:' found_names]);
end

