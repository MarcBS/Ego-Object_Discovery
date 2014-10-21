%% Applies the dimensionality reduction model based on
% Locality Sensitive Hashing on all the loaded samples.

addpath('../../Locality Sensitive Hashing;..;../SpatialPyramidMatching;../Utils;../LocalitySensitiveHashing');

% volume_path = 'D:';
volume_path = '/Volumes/SHARED HD';

nBits = 20;
path_features = [volume_path '/Video Summarization Objects/Features/Data PASCAL_07'];
path_folders = [volume_path '/Video Summarization Project Data Sets/PASCAL'];
% LAB All, pHOG L2, SPM All
used_feats = [1:45 46:213 726:4925];

%%%% Features extraction [1]
feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches
feature_params.lHOG = 3; % number of levels used for the P-HOG
feature_params.bHOG = 8; % number of bins used for the P-HOG

%%%% Spatial Pyramid Matching [1]
feature_params.M = 200; % dimensionality of the vocabulary used
feature_params.L = 2; % number of levels used in the SPM
load('../Vocabulary/vocabulary.mat'); % load vocabulary "V"
load('../Vocabulary/min_norm.mat');
load('../Vocabulary/max_norm.mat');

%%%% LSH Dimensionality Reduction
load([num2str(nBits) 'bits/tables.mat']); % load tables
load([num2str(nBits) 'bits/min_norm.mat']);
load([num2str(nBits) 'bits/max_norm.mat']);


%% Prepare initial variables

% Load objects
disp('LOADING OBJECTS file...');
load([path_features '/objects.mat']);

% Load image folders
imgs = dir([path_features '/img*']);
nImgs = length(imgs);

% Variable for storing all the features
features = [];
indicesLSH = [];

%% Loop over images
disp(['STARTING DIM.REDUCTION of ' num2str(nImgs) ' images...']);
for i = 1:nImgs
    %% Get objects for this image
    name_img = imgs(i).name;
    objs = dir([path_features '/' name_img '/obj*']);
    nObjs = length(objs);

    feat_img = zeros(nObjs, length(tables));
    ind_img = zeros(nObjs, 2);
    %% Loop over objects
    for j = 1:nObjs

        ind_img(j, :) = [i j];
        % Get features from current object and get only the selected ones
        [this_feat, ~] = recoverFeatures(objects, [i j], [], V, V_min_norm, V_max_norm, [], feature_params, path_features, false, '', '', [1 0]);
        this_feat = this_feat(used_feats);
        [this_feat] = normalize(this_feat, LSH_min_norm, LSH_max_norm);

        % Reduce dimensionality using LSH model
        feat_img(j,:) = getBucketIndicesSeeds(this_feat', tables);

    end
    
    % Stores features from current image in the whole set
    features = [features; feat_img];
    indicesLSH = [indicesLSH; ind_img];
    
    if(mod(i, 25) == 0 || i == nImgs)
        disp(['Processed ' num2str(i) '/' num2str(nImgs) ' images.']);
    end
        
end


%% Save result
save([path_features '/featuresLSH.mat'], 'features');
save([path_features '/indicesLSH.mat'], 'indicesLSH');
disp('Result Saved!');
