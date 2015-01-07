% clear all

% Location where all the tests results will be stored
volume_path = '/Volumes/SHARED HD';
tests_path = [volume_path '/Video Summarization Tests'];

%% Shows the results obtained from an algorithm execution
folder = [tests_path '/ExecutionResults/Exec_CNN_Refill_Ferrari_ObjVSNoObj_3'];
% discard_labels = {'car', 'train', 'bycicle', 'motorbike', 'bottle', 'chair', 'dish'};
discard_labels = {};

list_objects = dir([folder '/resultsObjects_*']);
list_scenes = dir([folder '/resultsScenes_*']);

version = 3; % version = {1, 2, 3}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% OBJECTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Retrieve Objects result
lenObjects = length(list_objects);

% Prepare result vectors
maxLabeled = 0;
totalLabeled = zeros(1, lenObjects);
maxLabeledPerClass = {};
totalLabeledPerClass = {};
classes = {};
accuracies = {};
purities = {};
precisions = {};
recalls = {};
total_accuracy = zeros(1, lenObjects);
purity = zeros(1, lenObjects);
precision = zeros(1, lenObjects);
recall = zeros(1, lenObjects);
fmeasure = zeros(1, lenObjects);
% Start search
for i = 1:lenObjects
    load([folder '/resultsObjects_' num2str(i) '.mat']); % record
    record = regexp(record, '\\n', 'split');
    
    % Get num samples labeled so far
    part = regexp(record{3}, '/', 'split');
    if(i==1) % get max samples only if its the first iteration
        part2 = regexp(part{2}, ' ', 'split');
        maxLabeled = str2num(part2{1});
    end
    part = regexp(part{1}, ' ', 'split');
    totalLabeled(i) = str2num(part{2});
    
    
    % Get specific results for each label
    next = 4;
    while(~strcmp(record{next}, ' '))
        part = regexp(record{next}, '" : ', 'split');
        % Find accuracy
        acc = str2num(part{2});
        % Find class
        class = regexp(part{1}, '"', 'split'); class = class{2};
        % Find class id
        id = find(ismember(classes,class));
            % New Label
        if(isempty(id) && isempty(find(ismember(discard_labels,class))) )
            classes{length(classes)+1} = class;
            id = length(classes);
            accuracies{id} = {};
        end
        
        % Insert accuracy into corresponding class id
        if(~isempty(id))
            accuracies{id}{i} = acc;
        end
        
        if(version >= 3)
           if(next > 4)
               next = next+1;
               %% Get purity for this class
               part = regexp(record{next}, '" : ', 'split');
               pur = str2num(part{2});
               purities{id}{i} = pur;
           end
           
           next = next+1;
           %% Get precision for this class
           part = regexp(record{next}, '" : ', 'split');
           prec = str2num(part{2});
           precisions{id}{i} = prec;
           
           next = next+1;
           %% Get recall for this class
           part = regexp(record{next}, '" : ', 'split');
           rec = str2num(part{2});
           recalls{id}{i} = rec;
        end
        
        if(version >= 2)
            next = next+1;
            %% Get total number of samples from this class
            part = regexp(record{next}, '" : ', 'split');
            maxLabeledPerClass{id} = str2num(part{2});
            
            next = next+1;
            %% Get number of samples currently labeled
            part = regexp(record{next}, '" : ', 'split');
            totalLabeledPerClass{id}{i} = str2num(part{2});
        end
        
        next = next+1;
    end
    
    % Get total accuracy
    part = regexp(record{next+1}, ': ', 'split');
    total_accuracies(i) = str2num(part{2});
    
    % Get purity
    part = regexp(record{next+2}, ': ', 'split');
    purity(i) = str2num(part{2});
    
    % Get precision
    part = regexp(record{next+3}, ': ', 'split');
    precision(i) = str2num(part{2});
    
    % Get recall
    part = regexp(record{next+4}, ': ', 'split');
    recall(i) = str2num(part{2});
    
    % Get fmeasure
    part = regexp(record{next+5}, ': ', 'split');
    fmeasure(i) = str2num(part{2});
end

%%% Define colors
colors = jet(length(classes));


%% Show objects results

%%% Accuracy, purity and frac. labeled plot
f = figure;
set(gca, 'FontSize', 10);
line(1:lenObjects, purity, 'Color', 'g', 'LineWidth', 2);
hold all;
line(1:lenObjects, total_accuracies, 'Color', 'b', 'LineWidth', 2);
line(1:lenObjects, totalLabeled/maxLabeled, 'Color', 'r', 'LineWidth', 2);

if(version >= 3)
    line(1:lenObjects, precision, 'Color', 'y', 'LineWidth', 2);
    line(1:lenObjects, recall, 'Color', 'black', 'LineWidth', 2);
    line(1:lenObjects, fmeasure, 'Color', 'c', 'LineWidth', 2);
    legend({'Purity', 'Accuracy', 'Frac. Labeled', 'Precision', 'Recall', 'F-Measure'}, 4);
else
    legend({'Purity', 'Accuracy', 'Frac. Labeled'}, 4);
end
title('General Measures', 'FontSize', 15);
xlabel('Iterations', 'FontSize', 15);


%%% Percentages of samples labeled plot
if(version >= 2)
    f = figure;
    set(gca, 'FontSize', 10);
    for i = 1:length(classes)
        per_class = zeros(1, lenObjects);
        for j = 1:lenObjects
            per_class(j) = totalLabeledPerClass{i}{j};
        end
        line(1:lenObjects, per_class./maxLabeledPerClass{i}, 'Color', colors(i,:), 'LineWidth', 2);
        hold all;
    end
    legend(classes);
    title('Fraction of samples labeled.', 'FontSize', 15);
    xlabel('Iterations', 'FontSize', 15);
end


%%% Objects accuracies plot
f = figure;
set(gca, 'FontSize', 10);
for i = 1:length(classes)
    acc = accuracies{i};
    accObj = [];
    iters = [];
    for j = 1:lenObjects
        if(~isempty(acc{j}))
            accObj = [accObj acc{j}];
            iters = [iters j];
        end
    end
    line(iters, accObj, 'Color', colors(i,:), 'LineWidth', 2);
    hold all;
end
legend(classes);
title('Accuracies.', 'FontSize', 15);
xlabel('Iterations', 'FontSize', 15);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SCENES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Retrieve Scenes result
lenObjects = length(list_scenes);

% Prepare result vectors
maxLabeled = 0;
totalLabeled = zeros(1, lenObjects);
classes = {};
accuracies = {};
total_accuracy = zeros(1, lenObjects);
% Start search
for i = 1:lenObjects
    load([folder '/resultsScenes_' num2str(i) '.mat']); % record
    record = regexp(record, '\\n', 'split');
    
    % Get num samples labeled so far
    part = regexp(record{3}, '/', 'split');
    if(i==1) % get max samples only if its the first iteration
        part2 = regexp(part{2}, ' ', 'split');
        maxLabeled = str2num(part2{1});
    end
    part = regexp(part{1}, ' ', 'split');
    totalLabeled(i) = str2num(part{2});
    
    
    % Get accuracy for each label
    next = 4;
    while(~strcmp(record{next}, ' '))
        part = regexp(record{next}, '" : ', 'split');
        % Find accuracy
        acc = str2num(part{2});
        % Find class
        class = regexp(part{1}, '"', 'split'); class = class{2};
        % Find class id
        id = find(ismember(classes,class));
            % New Label
        if(isempty(id))
            classes{length(classes)+1} = class;
            id = length(classes);
            accuracies{id} = {};
        end
        
        % Insert accuracy into corresponding class id
        accuracies{id}{i} = acc;
        
        next = next+1;
    end
    
    % Get total accuracy
    part = regexp(record{next+1}, ': ', 'split');
    total_accuracies(i) = str2num(part{2});

end


%% Show objects results

%%% Accuracy, purity and frac. labeled plot
f = figure;
set(gca, 'FontSize', 10);
line(1:lenObjects, total_accuracies, 'Color', 'b', 'LineWidth', 2);
hold all;
line(1:lenObjects, totalLabeled/maxLabeled, 'Color', 'r', 'LineWidth', 2);

legend({'Accuracy', 'Frac. Labeled'}, 4);
xlabel('Iterations', 'FontSize', 15);


%%% Objects accuracies plot
f = figure;
set(gca, 'FontSize', 10);
colors = jet(length(classes));
for i = 1:length(classes)
    acc = accuracies{i};
    accObj = [];
    iters = [];
    for j = 1:lenObjects
        if(~isempty(acc{j}))
            accObj = [accObj acc{j}];
            iters = [iters j];
        end
    end
    line(iters, accObj, 'Color', colors(i,:), 'LineWidth', 2);
    hold all;
end
legend(classes);
xlabel('Iterations', 'FontSize', 15);
