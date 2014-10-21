function [ objects, classes, found_labels ] = automaticLabelingScenes(objects, clusters, nMaxLabelClusters, indices, classes)
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
            k = indices(el);
            scene = objects(k);
            labels{count_el} = scene.labelScene; % insert label in list
            count_el = count_el +1;
        end
        %% Store majorityVoting result
        % Get majority label
        un_labels = unique(labels);
        n = zeros(length(un_labels), 1);
        for iy = 1:length(un_labels)
          n(iy) = length(find(strcmp(un_labels{iy}, labels)));
        end
        [v, p] = sort(n, 'descend');
        % Store {majorityLabel, allLabels, #majority}
        majorityLabel = un_labels(p(1));
        result{i} = {majorityLabel{1}, labels, v(1)};
    end
    
    %% Store resulting labels
    for i = 1:nClus
        labelName = result{i}{1};
        found_names = [found_names ' "' labelName '"'];
        labelId = find(ismember(labNames,labelName));
        % New Label
        if(isempty(labelId))
            labelId = length(classes)+1;
            classes(labelId).name = labelName;
            labNames{labelId} = labelName;
        end
        
        
        %% Insert label id to all samples in i-th cluster
        clus = clusters{i};
        for el = clus
            k = indices(el);
            objects(k).labelSceneRuntime = labelId;
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

