%%% This file plots the distribution of TRUE objects for each Narrative user
addpath('../Utils;../../Utils');

% volume_path = 'D:/';
volume_path = '/Volumes/SHARED HD/';
objects_path = [volume_path 'Video Summarization Objects/Features/Data Narrative_Dataset Ferrari'];

%% Load object counts
classes = {'lamp', 'aircon', 'cupboard', 'tvmonitor', 'door', 'face', ...
    'person', 'sign', 'hand', 'window', 'building', 'paper', 'bottle', ...
    'glass', 'chair', 'mobilephone', 'car', 'train', 'motorbike', ...
    'bicycle', 'dish'};

users_list = {'Petia', 'Maya', 'Estefania', 'Mariella'};
doNormalize = true;

% users.Petia = [1198 302 305 520 110 150 273 93 243 46 51 83 14 38 0 13 7 ...
%     1 5 0 0];
% users.Maya = [184 25 7 624 71 142 397 114 429 65 38 230 12 47 134 108 47 ...
%     3 2 2 5];
% users.Estefania = [184 9 27 1 5 230 363 146 397 25 477 18 175 707 2 6 179 ...
%     0 16 1 48];

%% Initialize counters
for u = users_list
    eval(['usersGT.' u{1} ' = zeros(1, ' num2str(length(classes)) ');']);
    eval(['usersObjectness.' u{1} ' = zeros(1, ' num2str(length(classes)) ');']);
    eval(['usersObjectnessUnique.' u{1} ' = zeros(1, ' num2str(length(classes)) ');']);
end


%% Get classes for each user
load([objects_path '/objects.mat']);
nImages = length(objects); count_empty = 0;
for i = 1:nImages
    user = objects(i).folder;
    user = regexp(user, '/', 'split');
    user = user{1}(1:end-1);
    nGT = length(objects(i).ground_truth);
    for j = 1:nGT
        if(~isempty(objects(i).ground_truth(j).name))
            id = find(ismember(classes, objects(i).ground_truth(j).name));
            eval(['usersGT.' user '(' num2str(id) ') = usersGT.' user '(' num2str(id) ') +1;']);
        else
            count_empty = count_empty+1;
        end
    end
    nObj = length(objects(i).objects);
    gt_ids = zeros(1,nObj);
    for j = 1:nObj
        id = find(ismember(classes, objects(i).objects(j).trueLabel));
        gt_id = objects(i).objects(j).trueLabelId;
        if(~isempty(id))
            if(isempty(find(gt_ids==gt_id)))
                gt_ids(j) = gt_id;
                eval(['usersObjectnessUnique.' user '(' num2str(id) ') = usersObjectnessUnique.' user '(' num2str(id) ') +1;']);
            end
            eval(['usersObjectness.' user '(' num2str(id) ') = usersObjectness.' user '(' num2str(id) ') +1;']);
        end
    end
end

%% Check distribution of objects among users
nUsers = length(users_list);
nClasses = length(classes);
objsGT = zeros(nUsers, nClasses);
objsObjectness = zeros(nUsers, nClasses);
objsObjectnessUnique = zeros(nUsers, nClasses);

for i = 1:nUsers
    objsGT(i,:) = eval(['usersGT.' users_list{i}]);
    objsObjectness(i,:) = eval(['usersObjectness.' users_list{i}]);
    objsObjectnessUnique(i,:) = eval(['usersObjectnessUnique.' users_list{i}]);
end

% Sort objects by number of samples
nObjsGT = sum(objsGT);
nObjsObjectness = sum(objsObjectness);
nObjsObjectnessUnique = sum(objsObjectnessUnique);
[nObjsGT, p] = sort(nObjsGT, 'descend');
nObjsObjectness = nObjsObjectness(p);
nObjsObjectnessUnique = nObjsObjectnessUnique(p);

if(doNormalize)
    objsGT = normalizeHistograms(objsGT(:,p));
    objsObjectness = normalizeHistograms(objsObjectness(:,p));
    objsObjectnessUnique = normalizeHistograms(objsObjectnessUnique(:,p));
%     objs = normalize(objs(:,p));
end

%% Define plot colors
c = colormap(jet);
close(gcf);
c = c(round(linspace(1,size(c,1)/10*8, nUsers)),:);

%% Plot
f = figure(1); hold on;
for i = 1:nUsers
    plot(1:nClasses, objsGT(i,:), 'Color', c(i,:), 'Marker', '+', 'LineWidth', 2, 'MarkerSize', 10);
end
% for i = 1:nUsers
%     plot(1:nClasses, objsObjectness(i,:), 'Color', c(i,:), 'Marker', 'o', 'LineWidth', 2, 'MarkerSize', 10);
% end
for i = 1:nUsers
    plot(1:nClasses, objsObjectnessUnique(i,:), 'Color', c(i,:), 'Marker', 'o', 'LineWidth', 2, 'MarkerSize', 10);
end

%% Set labels
ylabel('Relative %');
set(gca,'XLim', [1 nClasses], 'XTick', 1:nClasses, 'XTickLabel',{classes{p}});
xticklabel_rotate;
legend(users_list);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot total number of objects
f = figure(2);
bar([nObjsGT; nObjsObjectness; nObjsObjectnessUnique]');
ylabel('Number of instances', 'FontSize', 14);
set(gca,'XLim', [0 nClasses+1], 'XTick', 1:nClasses, 'XTickLabel',{classes{p}}, 'FontSize', 14);
xticklabel_rotate;
legend({'GT', 'Objectness', 'Objectness (unique)'});
set(gca, 'FontSize', 14);

disp('CLASSES:');
disp(classes);
disp('GT:');
disp(nObjsGT);
disp('Objectness:');
disp(nObjsObjectness);
disp('Objectness Unique:');
disp(nObjsObjectnessUnique);
disp('Done');