function record = checkLabeledInstancesScenes( objects, classes )
%CHECKLABELEDINSTANCES Evaluates the info of the already labeled instances.

    disp('=======================================');
    disp(' ');
    record = '=======================================\n\n';
    nImages = length(objects);

    labels = {};
    classes_names = {};
    for i = 1:length(classes)
        labels{i} = 0;
        classes_names = {classes_names{:}, classes(i).name};
    end
    
    %% Get labeled indices
    L = []; total = 0;
    for i = 1:nImages
        
        % Found a labeled instance
        lab = objects(i).labelSceneRuntime;
        initial = objects(i).initialSelection;
        if(isempty(initial))
            total = total+1;
        end
        if(~isempty(lab) && isempty(initial))
            L = [L; i];

            truelab = find(ismember(classes_names, objects(i).labelScene));
            % Add temporary new label
            if(isempty(truelab))
                classes_names = {classes_names{:}, objects(i).labelScene};
                truelab = length(classes_names);
                labels{truelab} = [];
            end
            % Count label assigned to sample with truelab
            labels{truelab} = [labels{truelab} lab];
        end

    end
    nLabeled = size(L,1);
    out = ['Labeled ' num2str(nLabeled) '/' num2str(total) ' objects so far.'];
    disp(out);
    record = [record out];
    
    %% Check instances found of each class
    r = resultMeasuresScenes(labels, classes_names, [0 0]);
    record = [record r '\n \n======================================='];
    
    disp(' ');
    disp('=======================================');


end

