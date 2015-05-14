%% Initial parameters
%
%   Note: always use '/' in the file paths.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% volume_path = 'D:';
% volume_path = 'C:';
% volume_path = '/Volumes/SHARED HD';
% volume_path = '/media/lifelogging';
volume_path = '';

% Location where all the tests results will be stored
% tests_path = [volume_path '/Video Summarization Tests'];
% tests_path = [volume_path '/HDD 2TB/Video Summarization Tests'];
tests_path = [volume_path 'D:/Video Summarization Tests'];
% tests_path = [volume_path '/Users/Lifelogging/Desktop/Video Summarization Tests'];

% rate used when choosing easy instances
%   1st -> times std.dev (1.25) with SVM classifier (2.35)?
%   2nd -> increased each interation (1/1000)
%   3rd -> max instances picked (1000, **5000** or 10000)
%   4th -> max number of iterations
easiness_rate = [1.25 1/1000 5000 100];
% easiness_rate = [-Inf 1/1000 5000 Inf];

%% Objectness parameters
objectness.W = 50; % number of object windows extracted for each image using the objectness measure (50)
% Ferrari: LINUX ONLY, BING: WINDOWS ONLY, MCG: LINUX or MAC ONLY!, SelectiveSearch: ??? WINDOWS works
% kind of objectness extraction used = {'Ferrari', 'BING', 'MCG', 'SelectiveSearch'}
objectness.type = 'Ferrari';
% Working path to store the model and the results of the BING objectness
objectness.workingpath = [tests_path '/BING model/'];
% Path to the location of the MCG code
% objectness.pathMCG = [volume_path '/Video Summarization Others/Objectness MCG'];
objectness.pathMCG = [volume_path '/HDD 2TB/Video Summarization Others/Objectness MCG'];
% Parameters for the Selective Search objectness measure
objectness.selectiveSearch.k = 100;
objectness.selectiveSearch.minSize = 100;
objectness.selectiveSearch.sigma = 0.8;
objectness.selectiveSearch.colorType = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
objectness.selectiveSearch.simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};

%% Image size parameters
prop_res = 1; % (SenseCam 4, PASCAL 1, MSRC 1.25, Perina 1.25, Toy Problem 1, Narrative_stnd 1) resize proportion for the loaded images --> size(img)/prop_res
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
cluster_params.similDist = 'euclidean'; % 'cosine' maybe better than 'euclidean'?
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
% Minimum percentage of purity of the refilled concepts for labeling (only
% used with abstract concept labeling, do_abstract_concept_discovery = true)
cluster_params.minPerPurityConcept = 0.8;
% If true, forces a new cluster with a refill sample assigned to it, to
% have a minimum similarity w.r.t. the concept cluster in the Bag of Refill (only
% used with abstract concept labeling, do_abstract_concept_discovery = true)
cluster_params.minSimilarityRefillConcept = true;
% Minimum number of samples for selecting a cluster (DEPRECATED)
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
cluster_params.max_similarity = 1; % (Obj+Evnt = 2, Obj+Evnt+Cntx = 3), maximum 
% similarity achieved by the samples for transforming it into a distance metric.

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
cluster_params.wardStdTimesIncreaseConcepts = 0.1; % percentage of increase used for the concept discovery when we have a low number of samples

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


%% Optional MAIN processes
reload_objStruct = false; % Builds the objects structure for executing the whole algorithm
reload_objectness = false; % Calculates the objectness and the objects candidates
reload_features = false; % recalculate features of each object candidate
reload_features_scenes = false; % recalculate features of each scene candidate
% retrain_obj_vs_noobj = false; % Rebuilds the SVM classifier ObjVSNoObj (DEPRECATED)
apply_obj_vs_noobj = false; % Applies the Obj VS NoObj SVM classifier as an initial filtering.
do_discovery = true; % Applies the object discovery algorithm on the data
do_abstract_concept_discovery = true; % Applies the abstract concept discovery instead of the normal object discovery
do_final_evaluation = false; % Does a final evaluation building SVM/KNN classifiers on the initialSamplesSelection

%% Optional PLOT processes
show_easiest = false; % sets if we want to store the easieast objects from each iteration in a folder
show_PCA = false; % shows the 2D/3D PCA representation of the samples
eval_clustering = false; % evaluates the result of the clustering (only possible if ground truth available).
show_clustering = false; % shows the result of the clustering
show_harderInstances = false; % shows the clusters labeled and the corresponding harder instances found with each of them.

%% Obj VS NoObj SVM classifier params
objVSnoobj_params.kernel = 'rbf';
%   SenseCam:       C=10    Sigma=100
%   PASCAL_12:      C=3     Sigma=100
%   MSRC:           C=3     Sigma=100
objVSnoobj_params.C = 3;
objVSnoobj_params.sigma = 100;
objVSnoobj_params.SVMpath = 'PASCAL_12'; % 'PASCAL_12' or 'MSRC'
% -t = RBF, -c = C, -g = gamma (Sigma), -e = epsilon (termination criterion) (default 0.001)
% objVSnoobj_params.svmParameters = '-s 0 -t 2 -c 10 -g 100 -q';
objVSnoobj_params.balance = true; % balance or not the classifier samples.
objVSnoobj_params.labels = [1 -1]; % [Obj NoObj] labels
objVSnoobj_params.evaluate = true; % show the evaluation of the classification result

%% Select which "AWARE" features are we going to use
feature_params.useScene = false;
feature_params.useEvent = false;
feature_params.useContext = false;
feature_params.useObject = false;

%% PCA options
feature_params.usePCA = false;
feature_params.minVarPCA = 0.95;
feature_params.standarizePCA = true;
feature_params.showPCAdim = 3; % 2 or 3 dimensions allowed (if show_PCA = true)

%% Classes of objects
classes = struct('name', [], 'label', []);
classes(1).name = 'Not Analyzed'; classes(1).label = 0;
classes(2).name = 'No Object'; classes(2).label = 1;

%% Classes of scenes
classes_scenes = zeros(0);

%% Histograms of classes of events
histClasses = zeros(0);

%% Features extraction (features location)
% feat_path = [volume_path '/Users/Lifelogging/Desktop/Obj_Disc PASCAL/Data SenseCam 0BC25B01 Ferrari']; % folder where we want to store the features for each object
feat_path = [volume_path '/HDD 2TB/Video Summarization Objects/Features/Data Narrative_Dataset Ferrari']; % folder where we want to store the features for each object
% feat_path = [volume_path '/Video Summarization Objects/Features/Data MSRC Ferrari']; % folder where we want to store the features for each object
has_ground_truth = true; % Determines if the ground truth is stored in the objects.mat file

% Grauman's features
feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram (15)
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation (16)
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches (10)
feature_params.lHOG = 3; % number of levels used for the P-HOG (2 better 'PASCAL_07 GT', 3 original)
feature_params.bHOG = 8; % number of bins used for the P-HOG (8)

% CNN features
feature_params.lenCNN = 4096; % length of the vector of features extracted from the CNN (4096)
feature_params.use_gpu = 1; % determines if we want to use the GPU for the CNN extraction
feature_params.batch_size = 10; % batch size for CNN extraction (given by the trained network)
feature_params.parallel = false; % defines if we want to load the batches in parallel or not
feature_params.caffe_path = '/usr/local/caffe-dev/matlab/caffe'; % path to caffe MEX
% Path to CNN model files (for features extraction)
feature_params.model_def_file = [pwd '/Caffe Src/bvlc_reference_caffenet/deploy_features.prototxt'];
feature_params.model_file = [pwd '/Caffe Src/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel'];

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
feature_params.initialObjectsPercentage = 0.4; % value between 0 and 1  (0.4)
feature_params.initialObjectsClassesOut = 0.5; % percentage of classes out of the initial selection  (0.5)

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
fold_name = regexp(feat_path, '/', 'split'); fold_name = fold_name{end};
feature_params.M = 200; % dimensionality of the vocabulary used (200)
feature_params.L = 2; % number of levels used in the SPM (2)
% Load Scenes vocabulary
try
    load(['Objects Recognition/Vocabulary/' fold_name '/vocabularyS.mat']); % load vocabulary "VS"
    load(['Objects Recognition/Vocabulary/' fold_name '/min_normS.mat']);
    load(['Objects Recognition/Vocabulary/' fold_name '/max_normS.mat']);
catch
    VS = ''; V_min_normS = ''; V_max_normS = '';
end
% Load Objects vocabulary
try
    load(['Objects Recognition/Vocabulary/' fold_name '/vocabulary.mat']); % load vocabulary "V"
    load(['Objects Recognition/Vocabulary/' fold_name '/min_norm.mat']);
    load(['Objects Recognition/Vocabulary/' fold_name '/max_norm.mat']);
catch
    V = ''; V_min_norm = ''; V_max_norm = '';
end

%% Supress some warnings
warning('off', 'MATLAB:rmpath:DirNotFound');
warning('off', 'MATLAB:MKDIR:DirectoryExists');
warning('off', 'parallel:cluster:FileStorageUnableToReadMetadata');

%% Set default parameters for objectness measures and paths to other functions
if(strcmp(objectness.type, 'Ferrari'))
    run 'Objectness Ferrari/objectness-release-v2.2/startup'
elseif(strcmp(objectness.type, 'MCG'))
    thispath = pwd;
    cd(objectness.pathMCG)
    run install
    cd(thispath)
end

% Add paths Objectness Measures
addpath(objectness.pathMCG);
addpath('Objectness SelectiveSearch;Objectness SelectiveSearch/Dependencies');
addpath('Objectness Ferrari/objectness-release-v2.2;Objectness BING');
addpath('Objects Recognition/FinalClassifiers;DimensionalityReduction');
% Add paths Object Recognition folder
addpath('Objects Recognition');
addpath('Objects Recognition/Utils');
addpath('Objects Recognition/ObjVSNoObj SVM');
addpath('Objects Recognition/SpatialPyramidMatching');
addpath('Objects Recognition/LocalitySensitiveHashing');
addpath('Objects Recognition/Complete-LinkClustering');
% Add paths auxiliar libraries
addpath('K_Means;Locality Sensitive Hashing;PHOG;SIFTflow/mexDenseSIFT');
addpath('Caffe Src;Concepts_Discovery');
path_svm = 'libsvm-3.18/matlab';


rmpath(path_svm);

%% Results storing folder
% results_folder = 'Exec_CNN_Refill_Ferrari_ObjVSNoObj_5';
results_folder = 'Exec_CNN_Refill_Ferrari_ObjVSNoObj_OneClassOut_2';

results_folder = [tests_path '/ExecutionResults/' results_folder];
mkdir(results_folder);

%% Folder Parsing Parameters (images location)
% path_folders = [volume_path '/Documentos/Vicon Revue Data'];
path_folders = [volume_path '/Video Summarization Project Data Sets/Narrative_Dataset'];
% path_folders = [volume_path '/Video Summarization Project Data Sets/PASCAL_12/VOCdevkit/VOC2012/'];
path_folders = [volume_path '/Shared SSD/Object Discovery Data/Video Summarization Project Data Sets/Narrative_Dataset'];
% path_labels = [volume_path '/Documentos/Dropbox/Video Summarization Project/Code/Subshot Segmentation/EventsDivision_SenseCam/Datasets'];
path_labels = ''; % path to the scene labels

%%%%%% Datasets

% %%% All My SenseCam
% folders = {'0BC25B01-7420-DD20-A1C8-3B2BD6C87CB0', '16F8AB43-5CE7-08B0-FD11-BA1E372425AB', ...
%     '2E1048A6ECT', '5FA739A3-AAC4-E84B-F7CB-2179AD879AE3', '6FD1B048-A2F2-4CAB-1EFE-266503F59CD3' ...
%     '819DC958-7BFE-DCC8-C792-B54B9641AA75', '8B6E4826-77F5-66BF-FCBA-4054D0E84B0B', ...
%     'A06514ED-60B5-BF77-5549-2ED885FD7788', 'B07CCAA9-FEBF-E8F3-B637-B021D652CA48', ...
%     'D3B168F2-40C8-7BAB-5DA2-4577404BAC7A'};
% format = '.JPG';

%%% Narrative_Dataset
folders = {'Petia1/JPEGImages', 'Petia2/JPEGImages', 'Maya1/JPEGImages', 'Maya2/JPEGImages', ...
	'Estefania1/JPEGImages', 'Estefania2/JPEGImages', 'Mariella1/JPEGImages', 'Mariella2/JPEGImages'};
format = '.jpg';

% %% PASCAL_07
% folders = {%'VOCtrainval_06-Nov-2007/VOCdevkit/VOC2007/JPEGImages', ...
%     'VOCtest_06-Nov-2007/VOCdevkit/VOC2007/JPEGImages'};
% format = '.jpg';

% %% PASCAL_12
% folders = {'JPEGImages'};
% format = '.jpg';

% %% MSRC
% folders = {'JPEGImages'};
% format = '.JPG';

%%% Perina Short
% folders = {'Perina Short Dataset'};
% format = '.jpg';

%%% Toy Problem
% folders = {'Toy Problem Dataset'};
% format = '.jpg';
