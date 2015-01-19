%%% This file plots the distribution of TRUE objects for each Narrative user
addpath('../Utils;../../Utils');

% volume_path = 'D:/';
volume_path = '/Volumes/SHARED HD/';
objects_path = [volume_path 'Video Summarization Objects/Features/Data Narrative_Dataset Ferrari'];

%% Load object counts
classes_base = {'lamp', 'aircon', 'cupboard', 'tvmonitor', 'door', 'face', ...
    'person', 'sign', 'hand', 'window', 'building', 'paper', 'bottle', ...
    'glass', 'chair', 'mobilephone', 'car'};%, 'train', 'motorbike', ...
%     'bicycle', 'dish'};

users_list = {'Petia', 'Maya', 'Estefania', 'Mariella'};
doNormalize = true;

font_size = 18;

%% Execution results parameters
showExecution = true;
execs_path = [volume_path 'Video Summarization Tests/ExecutionResults/'];
this_execs = {'Exec_Ferrari_Grauman_6', 'Exec_Ferrari_CNN_Refill_6', 'Exec_Ferrari_ObjVSNoObj_MSRC_CNN_Refill_6'};
this_execs_names = {'Grauman', 'CNN + Refill', 'CNN + Refill + Filter'};
markers_execs = {'x', 'o', 'v'};


%% Initialize counters
for u = users_list
    eval(['usersGT.' u{1} ' = zeros(1, ' num2str(length(classes_base)) ');']);
    eval(['usersObjectness.' u{1} ' = zeros(1, ' num2str(length(classes_base)) ');']);
    eval(['usersObjectnessUnique.' u{1} ' = zeros(1, ' num2str(length(classes_base)) ');']);
    if(showExecution)
        for i = 1:length(this_execs)
            eval(['usersExec' num2str(i) '.' u{1} ' = zeros(1, ' num2str(length(classes_base)) ');']);
        end
    end
end


%% Get classes for each user
load([objects_path '/objects.mat']);
objects_base = objects; clear objects;
nImages = length(objects_base); count_empty = 0;
for i = 1:nImages
    user = objects_base(i).folder;
    user = regexp(user, '/', 'split');
    user = user{1}(1:end-1);
    
    % Ground Truth
    nGT = length(objects_base(i).ground_truth);
    for j = 1:nGT
        if(~isempty(objects_base(i).ground_truth(j).name))
            id = find(ismember(classes_base, objects_base(i).ground_truth(j).name));
            eval(['usersGT.' user '(' num2str(id) ') = usersGT.' user '(' num2str(id) ') +1;']);
        else
            count_empty = count_empty+1;
        end
    end
    
    % Objectness results
    nObj = length(objects_base(i).objects);
    gt_ids = zeros(1,nObj);
    for j = 1:nObj
        id = find(ismember(classes_base, objects_base(i).objects(j).trueLabel));
        gt_id = objects_base(i).objects(j).trueLabelId;
        if(~isempty(id))
            if(isempty(find(gt_ids==gt_id)))
                gt_ids(j) = gt_id;
                eval(['usersObjectnessUnique.' user '(' num2str(id) ') = usersObjectnessUnique.' user '(' num2str(id) ') +1;']);
            end
            eval(['usersObjectness.' user '(' num2str(id) ') = usersObjectness.' user '(' num2str(id) ') +1;']);
        end
    end
end

%% Get classes for each user: Executions results
if(showExecution)
    for k = 1:length(this_execs)
        load([execs_path this_execs{k} '/objects_results.mat']); % objects
        load([execs_path this_execs{k} '/classes_results.mat']); % classes
        nImages = length(objects_base);
        for i = 1:nImages
            user = objects_base(i).folder;
            user = regexp(user, '/', 'split');
            user = user{1}(1:end-1);
            
            nObj = length(objects(i).objects);
            for j = 1:nObj
                if(isempty(objects(i).objects(j).initialSelection))
                    id = find(ismember(classes_base, classes(objects(i).objects(j).label + 1).name));
    %                 gt_id = objects(i).objects(j).trueLabelId;
                    if(~isempty(id))
    %                     if(isempty(find(gt_ids==gt_id)))
    %                         gt_ids(j) = gt_id;
    %                         eval(['usersObjectnessUnique.' user '(' num2str(id) ') = usersObjectnessUnique.' user '(' num2str(id) ') +1;']);
    %                     end
                        eval(['usersExec' num2str(k) '.' user '(' num2str(id) ') = usersExec' num2str(k) '.' user '(' num2str(id) ') +1;']);
                    end
                end
            end
        end
    end
end


%% Check distribution of objects among users
nUsers = length(users_list);
nClasses = length(classes_base);
objsGT = zeros(nUsers, nClasses);
objsObjectness = zeros(nUsers, nClasses);
objsObjectnessUnique = zeros(nUsers, nClasses);
if(showExecution)
    for k = 1:length(this_execs)
        eval(['objsExec' num2str(k) ' = zeros(nUsers, nClasses);']);
    end
end

for i = 1:nUsers
    objsGT(i,:) = eval(['usersGT.' users_list{i}]);
    objsObjectness(i,:) = eval(['usersObjectness.' users_list{i}]);
    objsObjectnessUnique(i,:) = eval(['usersObjectnessUnique.' users_list{i}]);
    if(showExecution)
        for k = 1:length(this_execs)
            eval(['objsExec' num2str(k) '(i,:) = usersExec' num2str(k) '.' users_list{i} ';']);
        end
    end
end

% Sort objects by number of samples
nObjsGT = sum(objsGT);
nObjsObjectness = sum(objsObjectness);
nObjsObjectnessUnique = sum(objsObjectnessUnique);
if(showExecution)
    for k = 1:length(this_execs)
        eval(['nObjsExec' num2str(k) ' = sum(objsExec' num2str(k) ');']);
    end
end
[nObjsGT, p] = sort(nObjsGT, 'descend');
nObjsObjectness = nObjsObjectness(p);
nObjsObjectnessUnique = nObjsObjectnessUnique(p);
if(showExecution)
    for k = 1:length(this_execs)
        eval(['nObjsExec' num2str(k) ' = nObjsExec' num2str(k) '(p);']);
    end
end

if(doNormalize)
    objsGT = normalizeHistograms(objsGT(:,p));
    objsObjectness = normalizeHistograms(objsObjectness(:,p));
    objsObjectnessUnique = normalizeHistograms(objsObjectnessUnique(:,p));
    if(showExecution)
        for k = 1:length(this_execs)
            eval(['objsExec' num2str(k) ' = normalizeHistograms(objsExec' num2str(k) '(:,p));']);
        end
    end

%     objs = normalize(objs(:,p));
end

%% Define plot colors
c = colormap(jet);
close(gcf);
c = c(round(linspace(1,size(c,1)/10*8, nUsers)),:);

%% Plot users separately
for i = 1:nUsers
    f = figure(i); hold on;
    plot(1:nClasses, objsGT(i,:), 'Color', c(i,:), 'Marker', '+', 'LineWidth', 2, 'MarkerSize', 10);
    plot(1:nClasses, objsObjectnessUnique(i,:), 'Color', c(i,:), 'Marker', 's', 'LineWidth', 2, 'MarkerSize', 10);
    leg = {'GT', 'Objectness (unique)'};
    if(showExecution)
        for k = 1:length(this_execs)
            plot(1:nClasses, eval(['objsExec' num2str(k) '(i,:)']), 'Color', c(i,:), 'Marker', markers_execs{k}, 'LineWidth', 2, 'MarkerSize', 10);
            leg = {leg{:}, this_execs_names{k}};
        end
    end
    %% Set labels
    title([users_list{i} ' Objects Distribution'], 'FontSize', font_size);
    ylabel('Relative %', 'FontSize', font_size);
    set(gca,'XLim', [1 nClasses], 'XTick', 1:nClasses, 'XTickLabel',{classes_base{p}}, 'FontSize', font_size);
    xticklabel_rotate;
    legend(leg);
    set(gca, 'FontSize', font_size);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot all users together
f = figure(length(users_list)+1); hold on;
for i = 1:nUsers
    plot(1:nClasses, objsGT(i,:), 'Color', c(i,:), 'Marker', '+', 'LineWidth', 2, 'MarkerSize', 10);
end
% for i = 1:nUsers
%     plot(1:nClasses, objsObjectness(i,:), 'Color', c(i,:), 'Marker', 'o', 'LineWidth', 2, 'MarkerSize', 10);
% end
for i = 1:nUsers
    plot(1:nClasses, objsObjectnessUnique(i,:), 'Color', c(i,:), 'Marker', 'o', 'LineWidth', 2, 'MarkerSize', 10);
end

if(showExecution)
    for k = 1:length(this_execs)
        for i = 1:nUsers
            plot(1:nClasses, eval(['objsExec' num2str(k) '(i,:)']), 'Color', c(i,:), 'Marker', markers_execs{k}, 'LineWidth', 2, 'MarkerSize', 10);
        end
    end
end

%% Set labels
ylabel('Relative %', 'FontSize', font_size);
set(gca,'XLim', [1 nClasses], 'XTick', 1:nClasses, 'XTickLabel',{classes_base{p}}, 'FontSize', font_size);
xticklabel_rotate;
legend(users_list);
set(gca, 'FontSize', font_size);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot total number of objects
f = figure(length(users_list)+2);
% toplot = [nObjsGT; nObjsObjectness; nObjsObjectnessUnique];
% leg = {'GT', 'Objectness', 'Objectness (unique)'};
toplot = [nObjsGT; nObjsObjectnessUnique];
leg = {'GT', 'Objectness (unique)'};
if(showExecution)
    for k = 1:length(this_execs)
        toplot = [toplot; eval(['nObjsExec' num2str(k)])];
        leg = {leg{:}, this_execs_names{k}};
    end
end
bar(toplot', 1.5, 'histc');
ylabel('Number of instances', 'FontSize', font_size);
set(gca,'XLim', [1 nClasses+1], 'XTick', 1:nClasses, 'XTickLabel',{classes_base{p}}, 'FontSize', font_size);
xticklabel_rotate;
legend(leg);
set(gca, 'FontSize', font_size);

disp('CLASSES:');
disp({classes_base{p}});
disp('GT:');
disp(nObjsGT);
disp('Objectness:');
disp(nObjsObjectness);
disp('Objectness Unique:');
disp(nObjsObjectnessUnique);
if(showExecution)
    for k = 1:length(this_execs)
        disp([this_execs_names{k} ', ' this_execs{k} ':']);
        disp(eval(['nObjsExec' num2str(k)]));
    end
end
disp('Done');