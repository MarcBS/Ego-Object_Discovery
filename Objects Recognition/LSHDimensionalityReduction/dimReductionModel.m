%% Creates a dimensionality reduction model based on
% Locality Sensitive Hashing using some randomly chosen samples.

addpath('../../Locality Sensitive Hashing;..;../SpatialPyramidMatching;../Utils');

% volume_path = 'D:';
volume_path = '/Volumes/SHARED HD';

nBits = 20;
nTables = 20;
nSamples = 10000;
nSampPerImage = 5;
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


%% Prepare initial variables

% Load objects
disp('LOADING OBJECTS file...');
load([path_features '/objects.mat']);

% Variable for storing all the chosen samples' features
randSamples = zeros(nSamples, length(used_feats));

% Load image folders
imgs = dir([path_features '/img*']);
nImgs = length(imgs);

% Select random images to sample
imgs_idx = randsample(1:nImgs, nImgs);

% Get nSampPerImage objects from each image
i = 1; count = 0; max_count = nSamples/nSampPerImage;

%% Loop over images
disp(['STARTING RETRIEVAL of ' num2str(nSamples) ' objects...']);
while count < max_count
    name_img = imgs(imgs_idx(i)).name;
    if(strcmp(name_img(1:3), 'img')) % if it is a valid image
        objs = dir([path_features '/' name_img '/obj*']);
        obj_idx = randsample(1:length(objs), length(objs));
        j = 1; count_obj = 0; max_obj = nSampPerImage;
        
        %% Loop over objects
        while count_obj < max_obj
            
            % Get features from current object
            [this_feat, ~] = recoverFeatures(objects, [imgs_idx(i) obj_idx(j)], [], V, V_min_norm, V_max_norm, [], feature_params, path_features, false, '', '', [1 0]);
            randSamples(count*nSampPerImage + count_obj +1,:) = this_feat(used_feats);

            if(mod(count*nSampPerImage + count_obj +1, 100) == 0)
                disp(['Processed ' num2str(count*nSampPerImage + count_obj +1) '/' num2str(nSamples)]);
            end
            count_obj = count_obj +1;
            j = j+1;
        end
        
        count = count +1;
    end
    i = i+1;
end

%% Normalization and LSH
[randSamples, LSH_min_norm, LSH_max_norm] = normalize(randSamples);
tables = lsh('lsh', nTables, nBits, size(randSamples,2), randSamples');

%% Save result
folder = [num2str(nBits) 'bits'];
mkdir(folder);
save([folder '/min_norm.mat'], 'LSH_min_norm');
save([folder '/max_norm.mat'], 'LSH_max_norm');
save([folder '/tables.mat'], 'tables');
disp('Result Saved!');
