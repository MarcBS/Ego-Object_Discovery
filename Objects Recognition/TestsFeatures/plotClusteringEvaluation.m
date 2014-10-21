
%% Plots the data obtained from the clustering evaluation
addpath('../Utils');

% Location where all the tests results will be stored
tests_path = '../../../../../../Video Summarization Tests';

% clustering_dir = '../Clusters Results/Clustering_Objects_k-means_PASCAL GT CNNfeatures 2';
% feat_path = 'D:/Video Summarization Objects/Features/Data PASCAL_07 GT';
clustering_dir = [tests_path '/Clusters Results/Clustering_Objects_ward_SenseCam NoPCA_iter1'];
feat_path = 'D:/Video Summarization Objects/Features/Data SenseCam 0BC25B01';

% Load results file and objects file
load([feat_path '/objects.mat']);
load([clustering_dir '/evalResults.mat']);
cluster_params.evaluationMethod = evalResults{2};   
cluster_params.evaluationPlot = true;

% List folders
clus_folders = dir([clustering_dir '/cluster_*']);
lenClus = length(clus_folders);
clus_fold_names = {};
for i = 1:lenClus
    cut_name = regexp(clus_folders(i).name, '_', 'split');
    clus_fold_names{i} = [cut_name{1} '_' sprintf('%04i', str2num(cut_name{2}))];
end
[~, sorted_idx] = sort(clus_fold_names);

% Get all indices and all clusters
indices = []; clusters = {}; nSamples = 0;
for i = 1:lenClus
    load([clustering_dir '/' clus_folders(sorted_idx(i)).name '/indices.mat']);
    indices = [indices; idx_c];
    clusters{i} = [(nSamples+1):(nSamples+size(idx_c,1))];
    nSamples = nSamples+size(idx_c,1);
end

% Show evaluation
result = evaluateClustering( objects, indices, clusters, cluster_params );
