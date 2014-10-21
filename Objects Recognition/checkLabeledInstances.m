function record = checkLabeledInstances( objects, classes )
%CHECKLABELEDINSTANCES Evaluates the info of the already labeled instances.

    disp('=======================================');
    disp(' ');
    record = '=======================================\n\n';
    nImages = length(objects);

    labels = {};
    % Counts of total labels existent for each class
    topCounts = {};
    % Classes names
    classes_names = {};
    for i = 2:length(classes)
        labels{classes(i).label} = 0;
        classes_names = {classes_names{:}, classes(i).name};
        topCounts = {topCounts{:}, getTopCountLabel(objects, classes(i).name)};
    end
    
    
    %% Get labeled indices
    L = []; nTotal = 0;
    for i = 1:nImages
        nObjects = length(objects(i).objects);
        for j = 1:nObjects
            % Found a labeled instance
            lab = objects(i).objects(j).label;
            initial = objects(i).objects(j).initialSelection;
            if(isempty(initial))
                nTotal = nTotal+1;
            end
            if(lab ~= 0 && isempty(initial))
                L = [L; i j];
                
                truelab = find(ismember(classes_names, objects(i).objects(j).trueLabel));
                % Add temporary new label
                if(isempty(truelab))
                    topCounts = {topCounts{:}, getTopCountLabel(objects, objects(i).objects(j).trueLabel)};
                    classes_names = {classes_names{:}, objects(i).objects(j).trueLabel};
                    truelab = length(classes_names);
                    labels{truelab} = [];
                end
                % Count label assigned to sample with truelab
                labels{truelab} = [labels{truelab} lab];
            end
        end
    end
    nLabeled = size(L,1);
    out = ['Labeled ' num2str(nLabeled) '/' num2str(nTotal) ' objects so far.'];
    disp(out);
    record = [record out];
    
    %% Check instances found of each class
    r = resultMeasures(labels, topCounts, classes_names, [0 0]);
    record = [record r '\n \n======================================='];
    
    disp(' ');
    disp('=======================================');


end

