%%% Trains the ObjVSNoObj SVM classifier

%% Parameters
volume_path = 'D:';
% volume_path = 'C:';
% volume_path = '/Volumes/SHARED HD';

feat_path = [volume_path '/Video Summarization Objects/Features/Data SenseCam 0BC25B01 Ferrari'];

classes = struct('name', [], 'label', []);
classes(1).name = 'Not Analyzed'; classes(1).label = 0;
classes(2).name = 'No Object'; classes(2).label = 1;

objVSnoobj_params.kernel = 'rbf';
%   SenseCam:       C=10    Sigma=100
%   PASCAL_12:      C=3     Sigma=100
%   MSRC:           C=3     Sigma=100
%   Narrative:      C=      Sigma=
objVSnoobj_params.C = 3;
objVSnoobj_params.sigma = 100;
objVSnoobj_params.SVMpath = 'PASCAL_12'; % 'PASCAL_12' or 'MSRC'
% -t = RBF, -c = C, -g = gamma (Sigma), -e = epsilon (termination criterion) (default 0.001)
% objVSnoobj_params.svmParameters = '-s 0 -t 2 -c 10 -g 100 -q';
objVSnoobj_params.balance = true; % balance or not the classifier samples.
objVSnoobj_params.labels = [1 -1]; % [Obj NoObj] labels

features_type = 'cnn';


fold_name = regexp(feat_path, '/', 'split'); fold_name = fold_name{end};
feature_params.M = 200; % dimensionality of the vocabulary used (200)
feature_params.L = 2; % number of levels used in the SPM (2)
% Load Objects vocabulary
try
    load(['../Vocabulary/' fold_name '/vocabulary.mat']); % load vocabulary "V"
    load(['../Vocabulary/' fold_name '/min_norm.mat']);
    load(['../Vocabulary/' fold_name '/max_norm.mat']);
end


feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram (15)
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation (16)
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches (10)
feature_params.lHOG = 3; % number of levels used for the P-HOG (2 better 'PASCAL_07 GT', 3 original)
feature_params.bHOG = 8; % number of bins used for the P-HOG (8)
feature_params.lenCNN = 4096; % length of the vector of features extracted from the CNN (4096)


prop_res = 1; % (SenseCam 4, PASCAL 1, MSRC 1.25, Perina 1.25, Toy Problem 1, Narrative_stnd 1) resize proportion for the loaded images --> size(img)/prop_res
% path_folders = [volume_path '/Video Summarization Project Data Sets/MSRC/'];
path_folders = [volume_path '/Vicon Revue Data/'];

addpath('../Utils');
addpath('..');

%% Load objects structure
load([feat_path '/objects.mat']);

%% Apply training
trainObjVSNoObj(objects, classes, objVSnoobj_params, features_type, V, V_min_norm, V_max_norm, feature_params, feat_path, path_folders, prop_res);