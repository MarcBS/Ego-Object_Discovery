%% This function prepares and formats the GT data for the MSRC dataset
%
% classes (marked the valid with '+'):
%
% building 1    +
% grass 2
% tree 3        +
% cow 4         +
% sheep 5       +
% sky 6
% mountain 7
% airplane 8    +
% water 9 
% car 10        +
% bicycle 11    +
% flower 12     +
% sign 13       +
% bird 14       +
% chair 15      +
% road 16
% body 17       +
% leaf 18       +
% chimney 19    +
% door 20       +
% window 21     +
%

volume_path = '/Volumes/SHARED HD/';
% volume_path = 'D:/';

path_imgs = [volume_path 'Video Summarization Project Data Sets/MSRC_not_processed/msrcorid'];
path_gt = [volume_path 'Video Summarization Project Data Sets/MSRC_not_processed/MSRCv0_GT'];
path_result = [volume_path 'Video Summarization Project Data Sets/MSRC'];

folders = {'/aeroplanes/general/'; '/aeroplanes/single/'; '/animals/cows/general/'; ...
    '/animals/cows/single/'; '/animals/sheep/general/'; '/animals/sheep/single/'; ...
    '/benches_and_chairs/'; '/bicycles/general/'; '/bicycles/side view, single/'; ...
    '/birds/general/'; '/birds/single/'; '/buildings/'; '/cars/front view/'; ...
    '/cars/general/'; '/cars/rear view/'; '/cars/side view/'; '/chimneys/'; ...
    '/doors/'; '/flowers/general/'; '/flowers/single/'; '/leaves/'; ...
    '/scenes/countryside/'; '/scenes/urban/'; '/signs/'; '/trees/general/'; ...
    '/trees/single/'; '/windows/'};

classes = {'building'; 'grass'; 'tree'; 'cow'; 'sheep'; 'sky'; 'mountain'; ...
    'airplane'; 'water';  'car'; 'bicycle'; 'flower'; 'sign'; 'bird'; ...
    'chair'; 'road'; 'body'; 'leaf'; 'chimney'; 'door'; 'window'};

% valid_classes = [1 0 1 1 1 0 0 1 0 1 1 1 1 1 1 0 1 1 1 1 1];
valid_classes = [8 8 4 4 5 5 15 11 11 14 14 1 10 10 10 10 19 20 12 12 18 3 ...
    16 13 3 3 21];

format = '.JPG';
prop_res = 1.25;
min_size = 0.0032; % minimum GT object area 0.32% of the whole image (~25x25 pixels)

version = 2;

%% Create destination folders
path_result_imgs = [path_result '/JPEGImages'];
path_result_anno = [path_result '/Annotations'];
mkdir(path_result_imgs);
mkdir(path_result_anno);

%% Start labels search
count = 1;
nFolders = length(folders);
for i = 1:nFolders
    this_path_gt = [path_gt folders{i}];
    this_path_imgs = [path_imgs folders{i}];
    files_gt = dir([this_path_gt '*.mat']);
    nFiles = length(files_gt);
    
    % For each file in this folder
    for j = 1:nFiles
        file_name = regexp(files_gt(j).name, '\.', 'split');
        img = [this_path_imgs file_name{1} format];
        
        % Load GT segmentation
        load([this_path_gt files_gt(j).name]); % gt_im
        gt_im = imresize(gt_im, [size(gt_im,1)/prop_res size(gt_im,2)/prop_res]);
        min_area = size(gt_im,1)*size(gt_im,2) * min_size;
        
        % Copy image and create annotations file
%         copyfile(img, [path_result_imgs '/' file_name{1} format]);
        anno_file = fopen([path_result_anno '/' file_name{1} '.xml'], 'w');
        
        % Get list of labels and write them to annotation file
        if(version == 1)
            labels = getLabels(gt_im, classes, valid_classes, version, min_area);
        elseif(version == 2)
            labels = getLabels(gt_im, classes, valid_classes(i), version, min_area);
        end
        nLabels = length(labels);
        for k = 1:nLabels
            newLabel = labels(k);
            fprintf(anno_file, '\t<object>\n');
            fprintf(anno_file, ['\t\t<name>' newLabel.name '</name>\n']);
            fprintf(anno_file, ['\t\t<xmin>' num2str(newLabel.ULx) '</xmin>\n']);
            fprintf(anno_file, ['\t\t<ymin>' num2str(newLabel.ULy) '</ymin>\n']);
            fprintf(anno_file, ['\t\t<xmax>' num2str(newLabel.BRx) '</xmax>\n']);
            fprintf(anno_file, ['\t\t<ymax>' num2str(newLabel.BRy) '</ymax>\n']);
            fprintf(anno_file, '\t</object>\n');
        end
        fclose(anno_file);
        
        %% Show progression
        if(mod(count,100)==0)
            disp(['Processed ' num2str(count) ' images.']);
        end
        count = count+1;
    end
end

disp('Finished processing images.');

