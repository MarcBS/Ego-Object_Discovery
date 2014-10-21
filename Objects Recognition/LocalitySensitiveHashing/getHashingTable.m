
%% Selects some samples randomly and builds a Locality Sensitive Hashing 
%   table for reducing the dimensionality of the feature-space.

addpath('../Utils;../SpatialPyramidMatching;../../Locality Sensitive Hashing');

%% Parameters
totalSamples = 20000; % total number of samples on which to apply LSH
nObjectsPerImage = 5; % number of objects sampled from each image

%%%% Objects loading
feat_path = 'D:\Video Summarization Objects\Features\Data 1'; % folder where we want to store the features for each object
load([feat_path '/objects.mat']);
W = 50;

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


%% Start random selection
nImages = totalSamples / nObjectsPerImage;
indices = zeros(totalSamples, 2);

randImages = randsample(1:length(objects), nImages);
count = 1;
for i = randImages
    randObjects = randsample(1:W, nObjectsPerImage);
    indices((count-1)*nObjectsPerImage+1:count*nObjectsPerImage, :) = [repmat(i, nObjectsPerImage, 1) randObjects'];
    count = count+1;
end

%% Get features from selected objects
[appearance_feat, ~] = recoverFeatures(objects, indices, [], V, [], feature_params, feat_path, false, '', '', [1 0]);
% Normalize
[appearance_feat, ~, ~] = normalize(appearance_feat);


%% Apply LSH and store result
LSH_tables = lsh('lsh', 100, 50, size(appearance_feat,2), appearance_feat');
save('LSH_tables.mat', 'LSH_tables');



