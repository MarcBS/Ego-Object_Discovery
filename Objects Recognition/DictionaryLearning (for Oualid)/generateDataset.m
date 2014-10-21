%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%                                          %%%%%%%%%%%%%%
%%%%%%%%%%%%%%      BEGIN PARAMETERS DEFINITION         %%%%%%%%%%%%%%
%%%%%%%%%%%%%%                                          %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% First and last images to copy to the output folder
initial_img = 1591;
final_img = 1690;


W = 50; % number of object windows extracted for each image using the objectness measure

%% Image size parameters
prop_res = 4; % (SenseCam 4, PASCAL 1, Perina 1.25) resize proportion for the loaded images --> size(img)/prop_res
max_size = 300; % max size by side for each image when extracting features

%% Features extraction
feat_path_input = 'D:\Video Summarization Objects\Features\Data All My SenseCam'; % input folder where to extract the data
feat_path_output = 'D:\Video Summarization Objects\Features\Data SenseCam Short'; % output folder for the generated data
feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches
feature_params.lHOG = 3; % number of levels used for the P-HOG
feature_params.bHOG = 8; % number of bins used for the P-HOG

%% Spatial Pyramid Matching
feature_params.M = 200; % dimensionality of the vocabulary used
feature_params.L = 2; % number of levels used in the SPM
load('../Vocabulary/vocabulary.mat'); % load vocabulary "V"

%% Set paths
addpath('../Utils;../SpatialPyramidMatching;../../K_Means;../../Locality Sensitive Hashing;..');

% WINDOWS
path_folders = 'D:\Documentos\Vicon Revue Data'; 
path_labels = 'D:\Documentos\Dropbox\Video Summarization Project\Code\Subshot Segmentation\EventsDivision_SenseCam\Datasets';

% All My SenseCam
folders = {'0BC25B01-7420-DD20-A1C8-3B2BD6C87CB0', '16F8AB43-5CE7-08B0-FD11-BA1E372425AB', ...
    '2E1048A6ECT', '5FA739A3-AAC4-E84B-F7CB-2179AD879AE3', '6FD1B048-A2F2-4CAB-1EFE-266503F59CD3' ...
    '819DC958-7BFE-DCC8-C792-B54B9641AA75', '8B6E4826-77F5-66BF-FCBA-4054D0E84B0B', ...
    'A06514ED-60B5-BF77-5549-2ED885FD7788', 'B07CCAA9-FEBF-E8F3-B637-B021D652CA48', ...
    'D3B168F2-40C8-7BAB-5DA2-4577404BAC7A'};
format = '.JPG';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%                                          %%%%%%%%%%%%%%
%%%%%%%%%%%%%%        END PARAMETERS DEFINITION         %%%%%%%%%%%%%%
%%%%%%%%%%%%%%                                          %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir(feat_path_output);
all_imgs = initial_img:final_img;

%% Load Objects
load([feat_path_input '/objects.mat']);
objects_out = struct('folder', [], 'imgName', [], 'idEvent', [], 'labelEvent', [], 'objects', struct('ULx', [], 'ULy', [], ...
        'BRx', [], 'BRy', [], 'objScore', [], 'eventAwareScore', [], 'label', 0));

%% Create output object and features_params structs
for i = 1:length(all_imgs)
    objects_out(i).folder = objects(all_imgs(i)).folder;
    objects_out(i).imgName = objects(all_imgs(i)).imgName;
    objects_out(i).idEvent = objects(all_imgs(i)).idEvent;
    objects_out(i).labelEvent = objects(all_imgs(i)).labelEvent;
    for j = 1:W
        objects_out(i).objects(j).ULx = objects(all_imgs(i)).objects(j).ULx;
        objects_out(i).objects(j).ULy = objects(all_imgs(i)).objects(j).ULy;
        objects_out(i).objects(j).BRx = objects(all_imgs(i)).objects(j).BRx;
        objects_out(i).objects(j).BRy = objects(all_imgs(i)).objects(j).BRy;
        objects_out(i).objects(j).objScore = objects(all_imgs(i)).objects(j).objScore;
        objects_out(i).objects(j).eventAwareScore = objects(all_imgs(i)).objects(j).eventAwareScore;
        objects_out(i).objects(j).label = objects(all_imgs(i)).objects(j).label;
    end
end
objects = objects_out;
save([feat_path_output '/objects.mat'], 'objects');
load([feat_path_input '/features_params.mat']);
features_params.L = feature_params.L;
features_params.M = feature_params.M;
save([feat_path_output '/features_params.mat'], 'features_params');

%% Copy each image information into new folder
count = 1; total = length(all_imgs)*W;
for i = 1:length(all_imgs)
    copyfile([feat_path_input '/img' num2str(all_imgs(i))], [feat_path_output '/img' num2str(all_imgs(i))]);
    % For each object candidate: extract window image and SPM features
    for j = 1:W
        % Get image and object in image
        img = objects(i);
        obj = objects(i).objects(j);
        
        % Extract object patch from image
        obj_img = imread([path_folders '/' img.folder '/' img.imgName]); % WINDOWS Y MAC
        obj_img = imresize(obj_img,[size(obj_img,1)/prop_res size(obj_img,2)/prop_res]);
        imwrite(obj_img, [feat_path_output '/img' num2str(all_imgs(i)) '/img' num2str(all_imgs(i)) '.jpg']);
        obj_img = obj_img(obj.ULy:obj.BRy, obj.ULx:obj.BRx, :);
        
        % Writes image
        imwrite(obj_img, [feat_path_output '/img' num2str(all_imgs(i)) '/obj' num2str(j) '.jpg']);
        
        % Extracts SPM features
        load([feat_path_output '/img' num2str(all_imgs(i)) '/obj' num2str(j) '.mat']);
        obj_feat.SPM_feat = spatialPyramidMatching(obj_feat.SIFT_feat, V, feature_params.L);
        save([feat_path_output '/img' num2str(all_imgs(i)) '/obj' num2str(j) '.mat'], 'obj_feat');
        
        % Count progress
        if(mod(count,10) == 0 || count == total)
            disp(['Information extracted from ' num2str(count) '/' num2str(total) ' objects.']);
        end
        count = count+1;
    end
end

disp('Done');