function record = checkLabeledInstances( objects, classes )
%CHECKLABELEDINSTANCES Evaluates the info of the already labeled instances.

    disp('=======================================');
    disp(' ');
    record = '=======================================\n\n';
    nImages = length(objects);

    %% Get samples NOT initial selection
    notInit = getSamplesNotInitialSelection(objects);
    
    %% Initialize variables
    labels = {};
    % Counts of total labels existent for each class
    topCounts = {};
    % Classes names
    classes_names = {};
    for i = 2:length(classes)
        labels{classes(i).label} = 0;
        classes_names = {classes_names{:}, classes(i).name};
        topCounts = {topCounts{:}, getTopCountLabel(objects, classes(i).name, notInit)};
    end
    
    
    %% Get labeled indices
    nLabeled = 0;
    nTotal = size(notInit,1);
    counts = zeros(1,length(classes_names));
    for ind = notInit'
        i = ind(1); j = ind(2);
        % Found a labeled instance
        lab = objects(i).objects(j).label;
        if(lab ~= 0)
            nLabeled = nLabeled+1;

            % Find label id in list of classes_names
            found = false; k = 1; nClasses = length(classes_names);
            truelabStr = objects(i).objects(j).trueLabel;
            truelab = [];
            while(~found && k <= nClasses)
                if(strcmp(classes_names{k}, truelabStr))
                    found = true;
                    truelab = k;
                end
                k = k+1;
            end

            % Add temporary new label
            if(isempty(truelab))
                topCounts = {topCounts{:}, getTopCountLabel(objects, objects(i).objects(j).trueLabel, notInit)};
                classes_names = {classes_names{:}, objects(i).objects(j).trueLabel};
                truelab = length(classes_names);
                counts(length(classes_names)) = 0;
                labels{truelab} = zeros(1, topCounts{length(classes_names)});
            end
            % Count label assigned to sample with truelab
            labels{truelab}(counts(truelab)+1) = lab;
            counts(truelab) = counts(truelab)+1;
        end
    end
    out = ['Labeled ' num2str(nLabeled) '/' num2str(nTotal) ' objects so far.'];
    disp(out);
    record = [record out];
    
    %% Check instances found of each class
    r = resultMeasures(labels, topCounts, classes_names, [0 0]);
    record = [record r '\n \n======================================='];
    
    disp(' ');
    disp('=======================================');


end

