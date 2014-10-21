
addpath('../Utils;../SpatialPyramidMatching');
% Location where all the tests results will be stored
tests_path = '../../../../../../Video Summarization Tests';

%% Parameters
folders_clusters = [tests_path '/Clusters Results/Clustering_Objects_lsh-k-means_ToyProblem_LAB'];
format = '.jpg';
typeGraphic = 'both'; % 'mean', 'variance', 'both' or 'all'
typeDivision = 'classes'; % 'classes' or 'clusters'
showingFeatures = 1600:1900; % (1:4925 all, 1:45 LAB, 46:725 PHOG, 726:4925 SPM)
%  46:85 L1 PHOG, 46:213 L1+L2 PHOG
%  726:925 L0 SPM, 726:1725 L0+L1 SPM

%%%% Features extraction
feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches
feature_params.lHOG = 3; % number of levels used for the P-HOG
feature_params.bHOG = 8; % number of bins used for the P-HOG

%%%% Spatial Pyramid Matching
feature_params.M = 200; % dimensionality of the vocabulary used
feature_params.L = 2; % number of levels used in the SPM
load('../Vocabulary/vocabulary.mat'); % load vocabulary "V"
load('../Vocabulary/min_norm.mat');
load('../Vocabulary/max_norm.mat');


%% Load objects file
feat_path = 'D:\Video Summarization Objects\Features\Data Toy Problem';
load([feat_path '/objects.mat']);

%% Get all files from all clusters/classes
clusters_feat = {};
clus_dir = dir([folders_clusters '/cluster_*']); clus_dir = clus_dir(3:end);
nClus = length(clus_dir);
nElems = zeros(1,nClus);
leg = {};
classes = {};
count_elems = 1;
for i = 1:nClus
    load([folders_clusters '/' clus_dir(i).name '/indices.mat']); % idx_c
    %% Read info from each image
    disp(['Cluster ' num2str(i)]);
    [appearance_feat, ~] = recoverFeatures(objects, idx_c, [], V, V_min_norm, V_max_norm, [], feature_params, feat_path, false, '', '', [1 0]);
    nElems(i) = size(appearance_feat,1);
    clusters_feat{i} = appearance_feat;
    if(strcmp(typeDivision,'classes'))
        nSamples = size(idx_c, 1);
        for s = 1:nSamples
            classes{count_elems} = objects(idx_c(s,1)).objects(idx_c(s,2)).trueLabel;
            count_elems = count_elems +1;
        end
    else
        leg{i} = ['Cluster ' num2str(i)];
    end
end

if(strcmp(typeDivision,'classes'))
    un_classes = unique(classes);
    lenClasses = length(un_classes);
    classes_id = zeros(length(classes), 1);
    count_el = 1;
    for c = classes
        classes_id(count_el) = find(strncmp(c{1}, un_classes, length(c{1})));
        count_el = count_el +1;
    end
    classesColour = jet(lenClasses); % define colors
    for i = 1:lenClasses
        leg{i} = [un_classes{i}];
    end
else
    classesColour = jet(nClus); % define colors
end

%% Put all features in a matrix
mat_feat = zeros(sum(nElems), size(clusters_feat{1},2));
idClus = zeros(sum(nElems), 1);
for i = 1:nClus
    if(i == 1)
        mat_feat(1:nElems(i), :) = clusters_feat{i};
        idClus(1:nElems(i)) = i;
    else
        mat_feat(sum(nElems(1:i-1))+1:sum(nElems(1:i-1))+nElems(i), :) = clusters_feat{i};
        idClus(sum(nElems(1:i-1))+1:sum(nElems(1:i-1))+nElems(i)) = i;
    end
end

%% Normalize
[mat_feat, ~, ~] = normalize(mat_feat);


%% Plot data

% Calculate mean for each class
if(strcmp(typeGraphic, 'mean'))
    f=figure;
    
    if(strcmp(typeDivision,'classes'))
        meanClasses = zeros(lenClasses, length(showingFeatures));
        for c = 1:lenClasses
            meanClasses(c, :) = mean(mat_feat(classes_id == c, showingFeatures));
            line(1:length(showingFeatures), meanClasses(c,:), 'Color', classesColour(c,:), 'LineWidth', 0.5);
            hold all;
        end
    elseif(strcmp(typeDivision,'clusters'))
        meanClusters = zeros(nClus, length(showingFeatures));
        for c = 1:nClus
            meanClusters(c, :) = mean(mat_feat(idClus == c, showingFeatures));
            line(1:length(showingFeatures), meanClusters(c,:), 'Color', classesColour(c,:), 'LineWidth', 0.5);
            hold all;
        end
    end
    addText = ' Mean';

% Calculate variance
elseif(strcmp(typeGraphic, 'variance'))
    f=figure;
    
    if(strcmp(typeDivision,'classes'))
        varClasses = zeros(lenClasses, length(showingFeatures));
        for c = 1:lenClasses
            varClasses(c, :) = var(mat_feat(classes_id == c, showingFeatures));
            line(1:length(showingFeatures), varClasses(c,:), 'Color', classesColour(c,:), 'LineWidth', 0.5);
            hold all;
        end
    elseif(strcmp(typeDivision,'clusters'))
        varClusters = zeros(nClus, length(showingFeatures));
        for c = 1:nClus
            varClusters(c, :) = var(mat_feat(idClus == c, showingFeatures));
            line(1:length(showingFeatures), varClusters(c,:), 'Color', classesColour(c,:), 'LineWidth', 0.5);
            hold all;
        end
    end
    addText = ' Variance';

% Calculate both variance and mean
elseif(strcmp(typeGraphic, 'both'))
    f=figure;
    
    if(strcmp(typeDivision,'classes'))
        % Plot one sample for each class for setting the correct legend
        for c = 1:lenClasses
            scatter(0,1, 1, classesColour(c,:));
            hold all;
        end
        set(gca,'xtick',[]);
        objs = findobj(gca,'Tag','Point');
        for c = 1:lenClasses
            boxplot(mat_feat(classes_id == c, showingFeatures), 'colors', classesColour(c,:), 'symbol', '+');
            hold all;
        end
    elseif(strcmp(typeDivision,'clusters'))
        % Plot one sample for each class for setting the correct legend
        for c = 1:nClus
            scatter(0,1, 1, classesColour(c,:));
            hold all;
        end
        objs = findobj(gca,'Tag','Point');
        for c = 1:nClus
            boxplot(mat_feat(idClus == c, showingFeatures), 'colors', classesColour(c,:), 'symbol', '+');
            hold all;
        end
    end
    % Set legend
    legend(objs,leg);
    addText = ' Variance and Mean';

% Plot only precise values sample by sample
elseif(strcmp(typeGraphic, 'all'))
    f=figure;
    
    if(strcmp(typeDivision,'classes'))
        % Loop used for defining the correct colors on the legend
        for c = 1:lenClasses
            this_feat = mat_feat(classes_id == c, showingFeatures);
            line(1:length(showingFeatures), this_feat(1,:), 'Color', classesColour(c,:), 'LineWidth', 0.5);
        end
        for c = 1:lenClasses
            this_feat = mat_feat(classes_id == c, showingFeatures);
            nSamples = size(this_feat,1);
            for s = 1:nSamples
                line(1:length(showingFeatures), this_feat(s,:), 'Color', classesColour(c,:), 'LineWidth', 0.5);
                hold all;
            end
        end
    elseif(strcmp(typeDivision,'clusters'))
        % Loop used for defining the correct colors on the legend
        for c = 1:nClus
            this_feat = mat_feat(idClus == c, showingFeatures);
            line(1:length(showingFeatures), this_feat(1,:), 'Color', classesColour(c,:), 'LineWidth', 0.5);
        end
        for c = 1:nClus
            this_feat = mat_feat(idClus == c, showingFeatures);
            nSamples = size(this_feat,1);
            for s = 1:nSamples
                line(1:length(showingFeatures), this_feat(s,:), 'Color', classesColour(c,:), 'LineWidth', 0.5);
                hold all;
            end
        end 
    end
        
    addText = ' Value';
end


% Insert legend
if(~strcmp(typeGraphic, 'both'))
    legend(leg);
end

% Insert Axis values
ylabel(addText);
xlabel('Features');

disp('Done');