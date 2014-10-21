%% Initial parameters

volume_path = 'D:';
% volume_path = '/Volumes/SHARED HD';

% Location where all the tests results will be stored
tests_path = [volume_path '/Video Summarization Tests'];

% rate used when choosing easy instances
%   1st -> times std.dev (2)
%   2nd -> increased each interation (0.1) (0.01?)
%   3rd -> max instances picked (1000, **5000** or 10000)
easines_rate = [1.25 1/100 5000];

%% Objectness parameters
objectness.W = 50; % number of object windows extracted for each image using the objectness measure (50)
% Ferrari: LINUX ONLY, BING: WINDOWS ONLY, MCG: LINUX or MAC ONLY!, SelectiveSearch: ??? WINDOWS works
% kind of objectness extraction used = {'Ferrari', 'BING', 'MCG', 'SelectiveSearch'}
objectness.type = 'SelectiveSearch'; 
% Working path to store the model and the results of the BING objectness
objectness.workingpath = [tests_path '/BING model/'];
% Path to the location of the MCG code
objectness.pathMCG = [volume_path '/Video Summarization Others/Objectness MCG'];
% Parameters for the Selective Search objectness measure
objectness.selectiveSearch.k = 100;
objectness.selectiveSearch.minSize = 100;
objectness.selectiveSearch.sigma = 0.8;
objectness.selectiveSearch.colorType = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
objectness.selectiveSearch.simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};

%% Image size parameters
prop_res = 4; % (SenseCam 4, PASCAL 1, Perina 1.25, Toy Problem 1) resize proportion for the loaded images --> size(img)/prop_res
max_size = 300; % max size by side for each image when extracting Grauman's features

%% Use of alternative kinds of features
% 'original' = LAB, pHOG and SPM; 
% 'lshDimReduc' = LSH Dimensionality  Reduction from original; 
% 'cnn' = Convolutional NN features; 
% 'cnn_con' = CNN object candidate + CNN scene
features_type = 'cnn';

%% Objects Clustering parameters (laveled clustering)
% {'lsh' = locality sensitive hashing, 'clink' = complete-link, 
% 'lsh-k-means' = LSH + K-means, 'k-means' = K-Means, 'ward' = agglomerative Ward} 
% kind of clustering used
cluster_params.clustering_type = {'ward'};
% Appearence features used at each clustering level
% (1:4925 all, 1:45 LAB, 46:725 PHOG, 726:4925 SPM)
%  46:85 L1 PHOG, 46:213 L1+L2 PHOGs
%  726:925 L0 SPM, 726:1725 L0+L1 SPM
%  1:4413 for PASCAL GT
%  1:4096 for CNN featuress
cluster_params.AppFeaturesLevels = {'all'};%{[1:45 46:213], 726:4925};
% SceneAware features used at each clustering level
cluster_params.SceneAwareFeaturesLevels = {[]};
% EventAware features used at each clustering level
cluster_params.EventAwareFeaturesLevels = {[]};
% ContextAware features used at each clustering level
cluster_params.ContextAwareFeaturesLevels = {[]};
% Maximum number of clusters to label in each iteration of the algorithm
cluster_params.nMaxLabelClusters = 1;
% Minimum number of samples for selecting a cluster (unused)
cluster_params.minCluster = 10;

%%% Testing only
% Named assigned to the cluster folder (if show_clustering = true or show_PCA = true)
cluster_params.clusName = 'SenseCam CNN concat';
% Mode of cluster showing (if show_clustering = true)
cluster_params.clusShowMode = 'best&worse'; % 'all' or 'best&worse'
% {'majorityVoting'}
% kind of evaluation metric used on the clustering result
cluster_params.evaluationMethod = 'majorityVoting';
cluster_params.consider_NoObject = true;
cluster_params.evaluationPlot = true;

%%%% Only used with Complete-Link clustering
cluster_params.max_similarity = 1; % (Obj+Evnt = 2, Obj+Evnt+Cntx = 3), maximum similarity achieved by the samples for transforming it into a distance metric.

%%%% Used in both LSH and LSH-K-Means
cluster_params.tLSH = 20; % number of tables created.
cluster_params.bLSH = 15; % (10-15 LAB?, 10 PHOG, 15-20 SPM, 10-15 all?) number of bits used on the cluster coding.
cluster_params.maxBucket = 300; % maximum number of samples in a single cluster (bucket) (150).

%%%% Only used with Locality Sensitive Hashing clustering
cluster_params.nSamplesCriterion = 20; % number of minimum samples used on the table selection criterion.
cluster_params.choosing_criterion = 'maxBig'; % {'minAvrg', 'maxBig'}

%%%% Only used with LSH-K-Means
cluster_params.fracSamplesCriterion = 4/5; % fraction of samples that must converge in order to stop k-means
cluster_params.nMaxIter = 50 ; % maximum iterations for stopping if convergence not achieved

%%%% Only used with K-Means
cluster_params.Kclusters = 60; % number of clusters created

%%%% Only used with Ward
cluster_params.wardStdTimes = 1.5; % std_deviation times used for the clustering cut criterion

%% Scene Clustering parameters (laveled clustering)
cluster_scn_params.AppFeaturesLevels = {'all'};
% ObjectAware features used at each clustering level
cluster_scn_params.ObjectAwareFeaturesLevels = {[]};
% Maximum number of clusters to label in each iteration of the algorithm
cluster_scn_params.nMaxLabelClusters = 2;
% Named assigned to the cluster folder if show_clustering = true
cluster_scn_params.clusName = 'SCENES';
% {'majorityVoting'}
% kind of evaluation metric used on the clustering result
cluster_scn_params.evaluationMethod = 'majorityVoting';
cluster_scn_params.evaluationPlot = true;
cluster_scn_params.minCluster = 10; % minimum number of samples for selecting a cluster

%%%% Only used with K-Means
cluster_scn_params.Kclusters = 10; % number of clusters created


%% Optional processes
reload_objStruct = false; % Builds the objects structure for executing the whole algorithm
reload_objectness = true; % Calculates the objectness and the objects candidates
reload_features = false; % CNN ONLY VALID IN LINUX! recalculate features of each object candidate
reload_features_scenes = false; % recalculate features of each scene candidate
show_easiest = false; % sets if we want to store the easieast objects from each iteration in a folder
show_PCA = false; % shows the 2D/3D PCA representation of the samples
eval_clustering = true; % evaluates the result of the clustering (only possible if ground truth available).
show_clustering = false; % shows the result of the clustering
show_harderInstances = false; % shows the clusters labeled and the corresponding harder instances found with each of them.

%% Classes of objects
classes = struct('name', [], 'label', []);
classes(1).name = 'Not Analyzed'; classes(1).label = 0;
classes(2).name = 'No Object'; classes(2).label = 1;

%% Classes of scenes
classes_scenes = zeros(0);

%% Histograms of classes of events
histClasses = zeros(0);

%% Features extraction (features location)
feat_path = [volume_path '/Video Summarization Objects/Features/Data SenseCam 0BC25B01 SelectiveSearch']; % folder where we want to store the features for each object
% feat_path = [volume_path '/Video Summarization Objects/Features/Data PASCAL_07 BING']; % folder where we want to store the features for each object
has_ground_truth = true; % Determines if the ground truth is stored in the objects.mat file

feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram (15)
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation (16)
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches (10)
feature_params.lHOG = 3; % number of levels used for the P-HOG (2 better 'PASCAL_07 GT', 3 original)
feature_params.bHOG = 8; % number of bins used for the P-HOG (8)
feature_params.lenCNN = 4096; % length of the vector of features extracted from the CNN (4096)

%% Select which "AWARE" features are we going to use
feature_params.useScene = false;
feature_params.useEvent = false;
feature_params.useContext = false;
feature_params.useObject = false;

%% PCA options
feature_params.usePCA = true;
feature_params.minVarPCA = 0.95;
feature_params.standarizePCA = true;
feature_params.showPCAdim = 3; % 2 or 3 dimensions allowed (if show_PCA = true)

%% Scene Awareness version
feature_params.scene_version = 1; % {1 or 2}

%% Refill percentage (0.2), if 0.0 then refill disabled
% Maximum percentage of samples from the ones clustered that will 
% be refilled from the labeled pool (distributed between all classes 
% but "No Object")
refill = 0.2;

%% Maximum number of samples used to calculate the SceneAwareness
feature_params.maxSceneAwarenessSamples = 100;
feature_params.maxObjectAwarenessSamples = 100;

%% Percentage of samples used for the initial Scene/Context/Event/Object awareness samples
feature_params.initialScenesPercentage = 1; % value between 0 and 1
feature_params.initialObjectsPercentage = 0.4; % value between 0 and 1

%% OneClass SVM parameters (see LIBSVM README)
% -s  SVM type (2 = one-class SVM)
% -n  nu value
% -t  kernel type (0 = linear, 2 = RBF)
% -c  C value
% -q  quite mode
svmParameters = '-s 2 -n 0.1 -q';

%% Final classifiers parameters
final_params.KNN = 5;
% RBF
% final_params.SVM = '-s 0 -t 2 -n 0.1 -c 1 -q';
% Linear
final_params.SVM = '-s 0 -t 0 -c 1 -q';

%% Spatial Pyramid Matching
feature_params.M = 200; % dimensionality of the vocabulary used (200)
feature_params.L = 2; % number of levels used in the SPM (2)
% Load Scenes vocabulary
load('Vocabulary/vocabularyS.mat'); % load vocabulary "VS"
load('Vocabulary/min_normS.mat');
load('Vocabulary/max_normS.mat');
% Load Objects vocabulary
load('Vocabulary/vocabulary.mat'); % load vocabulary "V"
load('Vocabulary/min_norm.mat');
load('Vocabulary/max_norm.mat');

%% Set default parameters for objectness measures and paths to other functions
if(strcmp(objectness.type, 'Ferrari'))
    run '../Objectness Ferrari/objectness-release-v2.2/startup'
elseif(strcmp(objectness.type, 'MCG'))
    thispath = pwd;
    cd(objectness.pathMCG)
    run install
    cd(thispath)
end
addpath(objectness.pathMCG);
addpath('../Objectness Ferrari/objectness-release-v2.2;../libsvm-3.18/windows;FinalClassifiers;../DimensionalityReduction');
addpath('Utils;SpatialPyramidMatching;../K_Means;../Locality Sensitive Hashing;LocalitySensitiveHashing;Complete-LinkClustering;../Objectness BING');
addpath('../Objectness SelectiveSearch;../Objectness SelectiveSearch/Dependencies');

%% Results storing folder
results_folder = 'Execution_CNN_Refill_BING_1';

results_folder = [tests_path '/ExecutionResults/' results_folder];
mkdir(results_folder);

%% Folder Parsing Parameters (images location)

%%% LINUX
% path_folders = '/home/marc/Desktop/Data Object Recognition';
% path_labels = '';

%%% WINDOWS & MAC
path_folders = [volume_path '/Documentos/Vicon Revue Data'];
% path_folders = [volume_path '/Video Summarization Project Data Sets/PASCAL'];
path_labels = [volume_path '/Documentos/Dropbox/Video Summarization Project/Code/Subshot Segmentation/EventsDivision_SenseCam/Datasets'];


%%%%%% Datasets

%%% All My SenseCam
folders = {'0BC25B01-7420-DD20-A1C8-3B2BD6C87CB0', '16F8AB43-5CE7-08B0-FD11-BA1E372425AB', ...
    '2E1048A6ECT', '5FA739A3-AAC4-E84B-F7CB-2179AD879AE3', '6FD1B048-A2F2-4CAB-1EFE-266503F59CD3' ...
    '819DC958-7BFE-DCC8-C792-B54B9641AA75', '8B6E4826-77F5-66BF-FCBA-4054D0E84B0B', ...
    'A06514ED-60B5-BF77-5549-2ED885FD7788', 'B07CCAA9-FEBF-E8F3-B637-B021D652CA48', ...
    'D3B168F2-40C8-7BAB-5DA2-4577404BAC7A'};
format = '.JPG';

% %%% Narrative
% folders = {'Narrative Samples'};
% format = '.jpg';

% %% PASCAL_07
% folders = {%'VOCtrainval_06-Nov-2007/VOCdevkit/VOC2007/JPEGImages', ...
%     'VOCtest_06-Nov-2007/VOCdevkit/VOC2007/JPEGImages'};
% format = '.jpg';

%%% Perina Short
% folders = {'Perina Short Dataset'};
% format = '.jpg';

%%% Toy Problem
% folders = {'Toy Problem Dataset'};
% format = '.jpg';

