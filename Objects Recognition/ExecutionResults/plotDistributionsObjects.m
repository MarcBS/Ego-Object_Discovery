%%% This file plots the distribution of TRUE objects for each Narrative user
addpath('../Utils;../../Utils');

%% Load object counts
classes = {'lamp', 'aircon', 'cupboard', 'tvmonitor', 'door', 'face', ...
    'person', 'sign', 'hand', 'window', 'building', 'paper', 'bottle', ...
    'glass', 'chair', 'mobilephone', 'car', 'train', 'motorbike', ...
    'bicycle', 'dish'};

users_list = {'Petia', 'Maya', 'Estefania'};

users.Petia = [1198 302 305 520 110 150 273 93 243 46 51 83 14 38 0 13 7 ...
    1 5 0 0];
users.Maya = [184 25 7 624 71 142 397 114 429 65 38 230 12 47 134 108 47 ...
    3 2 2 5];
users.Estefania = [184 9 27 1 5 230 363 146 397 25 477 18 175 707 2 6 179 ...
    0 16 1 48];

doNormalize = true;


%% Check distribution of objects among users
nUsers = length(users_list);
nClasses = length(classes);
objs = zeros(nUsers, nClasses);

for i = 1:nUsers
    objs(i,:) = eval(['users.' users_list{i}]);
end

% Sort objects by number of samples
nObjs = sum(objs);
[nObjs, p] = sort(nObjs, 'descend');

if(doNormalize)
%     objs = normalizeHistograms(objs(:,p));
    objs = normalize(objs(:,p));
end

%% Define plot colors
c = colormap(jet);
close(gcf);
c = c(round(linspace(1,size(c,1)/10*9, nUsers)),:);

%% Plot
f = figure(1); hold on;
for i = 1:nUsers
    plot(1:nClasses, objs(i,:), 'Color', c(i,:), 'Marker', '+');
end

%% Set labels
ylabel('Relative %');
set(gca,'XLim', [1 nClasses], 'XTick', 1:nClasses, 'XTickLabel',{classes{p}});
xticklabel_rotate;
legend(users_list);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot total number of objects
f = figure(2);
bar(nObjs);
ylabel('Number of instances');
set(gca,'XLim', [1 nClasses], 'XTick', 1:nClasses, 'XTickLabel',{classes{p}});
xticklabel_rotate;


disp('Done');