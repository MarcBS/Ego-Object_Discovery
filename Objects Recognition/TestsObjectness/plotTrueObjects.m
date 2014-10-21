%% Initial parameters

% Location where all the tests results will be stored
tests_path = '../../../../../../Video Summarization Tests';

show_N_imgs = 20; % number of images that will be showed

colours = {'r';'g';'b'}; % No Object, ground truth and true objects colors respectively

W = 50; % number of object windows extracted for each image using the objectness measure
prop_res = 4; % (SenseCam 4, PASCAL 1) resize proportion for the loaded images --> size(img)/prop_res
feat_path = 'D:\Video Summarization Objects\Features\Data SenseCam 0BC25B01'; % folder where we want to store the features for each object
max_size = 300; % max size by side for each image when extracting features
reload_objectness = false; % ONLY VALID ON LINUX! Builds the "objects" structure again calculatin the objectness and the objects candidates

%%%% Set default parameters for objectness measure and paths
run '../../Objectness Measure/objectness-release-v2.2/startup'
addpath('../../Objectness Measure/objectness-release-v2.2');

store_folder = [tests_path '/TestsObjectness/' 'Images_SenseCam_Ferrari2'];

%%%% Folder Parsing Parameters

% LINUX
% path_folders = '/home/marc/Desktop/Data Object Recognition'; 

% WINDOWS
% tmp (PASCAL)
% path_folders = 'D:\Video Summarization Project Data Sets\PASCAL\VOCtest_06-Nov-2007\VOCdevkit\VOC2007';
path_folders = 'D:\Documentos\Vicon Revue Data'; 
path_labels = 'D:\Documentos\Dropbox\Video Summarization Project\Code\Subshot Segmentation\EventsDivision_SenseCam\Datasets';

folders = {'0BC25B01-7420-DD20-A1C8-3B2BD6C87CB0', '16F8AB43-5CE7-08B0-FD11-BA1E372425AB', ...
    '2E1048A6ECT', '5FA739A3-AAC4-E84B-F7CB-2179AD879AE3', '6FD1B048-A2F2-4CAB-1EFE-266503F59CD3' ...
    '819DC958-7BFE-DCC8-C792-B54B9641AA75', '8B6E4826-77F5-66BF-FCBA-4054D0E84B0B', ...
    'A06514ED-60B5-BF77-5549-2ED885FD7788', 'B07CCAA9-FEBF-E8F3-B637-B021D652CA48', ...
    'D3B168F2-40C8-7BAB-5DA2-4577404BAC7A'};
% folders = {'JPEGImages'}; % PASCAL
format = '.JPG'; 
% format = '.jpg';


mkdir(store_folder);

%% Go through each folder getting list of images and labels
disp('PARSING FOLDERS looking for all images...');
[ list_img, list_event, list_event2 ] = parseFolders( folders, path_folders, format, path_labels );


%% Extract W objects (using objectness) for each image

%  ONLY VALID ON LINUX!!
%  Load objects.mat instead.
if(reload_objectness)
    disp(['EXTRACTING ' num2str(W) ' OBJECTS and objectness per image for all images...']);
    objects = extractObjects(list_img, prop_res, list_event, list_event2, W);
    save([feat_path '/objects.mat'], 'objects');
else
    disp('LOADING OBJECTS FILE...');
    load([feat_path '/objects.mat']);
%     load('../objects_SenseCam_4_multinomial.mat');
end

%% Show objects on images

% Go through each image
for i = 1:show_N_imgs
    img = [path_folders '/' objects(i).folder '/' objects(i).imgName];
    img = imread(img);
    img_ = imresize(img,[size(img,1)/prop_res size(img,2)/prop_res]);
    
    %% ground truth
    f = figure; imshow(img_);
    nGT = length(objects(i).ground_truth);
    for j = 1:nGT
        obj = objects(i).ground_truth(j);
        %# draw a rectangle
        rectangle('Position',[obj.ULx obj.ULy obj.BRx-obj.ULx obj.BRy-obj.ULy], 'LineWidth',2, 'EdgeColor', colours{2});
    end
    %% true objects
    nObjs = length(objects(i).objects);
    for j = 1:nObjs
        obj = objects(i).objects(j);
        if(~strcmp('No Object', obj.trueLabel))
            %# draw a rectangle
            rectangle('Position',[obj.ULx obj.ULy obj.BRx-obj.ULx obj.BRy-obj.ULy], 'LineWidth',2, 'EdgeColor', colours{3});
        end
    end
    saveas(f, [store_folder '/' objects(i).folder(1:8) '_' objects(i).imgName '_GT.jpg'], 'jpg');
    close(gcf);
    
    %% No Objects
    f = figure; imshow(img_);
    nObjs = length(objects(i).objects);
    for j = 1:nObjs
        obj = objects(i).objects(j);
        if(strcmp('No Object', obj.trueLabel))
            %# draw a rectangle
            rectangle('Position',[obj.ULx obj.ULy obj.BRx-obj.ULx obj.BRy-obj.ULy], 'LineWidth',2, 'EdgeColor', colours{1});
        end
    end
    saveas(f, [store_folder '/' objects(i).folder(1:8) '_' objects(i).imgName '_NoObjects.jpg'], 'jpg');
    close(gcf);
end

