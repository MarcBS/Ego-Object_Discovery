
addpath('../..;../../SpatialPyramidMatching');

%% Parameters
% path_features = 'D:\Video Summarization Objects\Features\Data PASCAL_07 GT';
% path_folders = 'D:\Video Summarization Project Data Sets\PASCAL';

path_features = 'D:\Video Summarization Objects\Features\Data CIFAR-10 GT';
path_folders = 'D:\Video Summarization Project Data Sets\CIFAR-10';

features_type = 'image';  % 'grauman' Grauman paper (Learning the Easy Things First [1])
                        % 'raw' raw rgb image with values normalized [2]
                        % 'image' whole image without being trainsformed to
                        % a vector [3]

%%%% Image rescaling [3]
scale_img2 = [256 256];                        

%%%% Image rescaling [2]
scale_img = [32 32];
                        
%%%% Features extraction [1]
feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches
feature_params.lHOG = 2; % number of levels used for the P-HOG
feature_params.bHOG = 8; % number of bins used for the P-HOG

%%%% Spatial Pyramid Matching [1]
feature_params.M = 200; % dimensionality of the vocabulary used
feature_params.L = 2; % number of levels used in the SPM
load('../../Vocabulary/vocabulary.mat'); % load vocabulary "V"
load('../../Vocabulary/min_norm.mat');
load('../../Vocabulary/max_norm.mat');

% Store all classes
classes = struct('name', []);
targets = [];

%% Load Objects
load([path_features '/objects.mat']);
indices = [];
for i = 1:length(objects)
    img = objects(i);
    for j = 1:length(objects(i).objects)
        indices = [indices; [i j]];
        
        %% Get labels list (GT)
        this_label = objects(i).objects(j).trueLabel;
        if(isempty(targets))
            classes(1).name = this_label;
            this_id = 1;
        else
            found = false; k = 1;
            while(~found && k <= length(classes))
                if(strcmp(classes(k).name, this_label))
                    this_id = k; found = true;
                end
                k = k+1;
            end
            if(~found)
                this_id = length(classes)+1;
                classes(this_id).name = this_label;
            end
        end
        targets = [targets; this_id];
    end
end

%% Create directory for saving info
out_dir = [path_features '/GT_' features_type];
mkdir(out_dir);

%% Get features if 'grauman' features_type
if(strcmp(features_type, 'grauman'))
    [features, ~] = recoverFeatures(objects, indices, [], V, V_min_norm, V_max_norm, [], feature_params, path_features, false, '', '', [1 0]);
elseif(strcmp(features_type, 'raw'))
    features = getRawImageFeatures(objects, indices, scale_img, path_folders);
elseif(strcmp(features_type, 'image'))
    getImage(objects, indices, scale_img2, path_folders, out_dir);
else
    throw(MException('MATLAB:InvalidParameter', ['Invalid features type "' features_type '".']));
end
    
%% Save features, targets and unique classes
if(~strcmp(features_type, 'image'))
    save([out_dir '/features.mat'], 'features');
end
save([out_dir '/targets.mat'], 'targets');
save([out_dir '/classes.mat'], 'classes');
save([out_dir '/indices.mat'], 'indices');
disp('Done');
