
%% This script builds a new dataset only composed by the Ground Truth 
    %   objects from the PASCAL challenge dataset folders.

path_folders = 'D:\Video Summarization Project Data Sets\CIFAR-10';
folders = { 'train' };
path_features = {'D:\Video Summarization Objects\Features\Data CIFAR-10 GT'};

%% Build struct for storing all objects found and their classes
objects = struct('folder', [], 'imgName', [], 'idEvent', [], 'labelEvent', [], 'objects', struct('ULx', [], 'ULy', [], ...
    'BRx', [], 'BRy', [], 'trueLabel', [], 'objScore', [], 'eventAwareScore', [], 'features', [], 'label', 0));

img_size = [32 32];

%% Go through each folder
offset = 0;
nFolders = length(folders);
for i = 1:nFolders

    %% List all .xml files with annotations
    disp('# READ annotations file');
    annotations = fileread([path_folders '/trainLabels.csv']);
    annotations = regexp(annotations, '\n', 'split');
    annotations = {annotations{2:end-1}};

    %% Get annotation for each image
    lenAnn = length(annotations);
    countAnn = 1;
    disp('# READING OBJECTS...');
    for j = 1:lenAnn
        %% Initialize info for this image
        this_ann = regexp(annotations{j}, ',', 'split');
        objects(j+offset).folder = folders{i};
        objects(j+offset).imgName = [this_ann{1} '.png'];
        objects(j+offset).idEvent = 1;
        objects(j+offset).labelEvent = 1;
        
        %% Get all attributes
        objects(j+offset).objects(1).trueLabel = this_ann{2};
        objects(j+offset).objects(1).ULx = 1;
        objects(j+offset).objects(1).ULy = 1;
        objects(j+offset).objects(1).BRx = img_size(2);
        objects(j+offset).objects(1).BRy = img_size(1);
        objects(j+offset).objects(1).objScore = 0;
        objects(j+offset).objects(1).eventAwareScore = 0;

        %% Check progress of annotations readed
        if(mod(countAnn, 100) == 0 || countAnn == lenAnn)
            disp(['Annotation files read: ' num2str(countAnn) '/' num2str(lenAnn)]);
        end
        countAnn = countAnn+1;
    end 
    disp(' ');
    
    offset = offset+lenAnn;
end

%% Save objects
save([path_features{1} '/objects.mat'], 'objects');

disp('CIFAR-10 dataset building finished.');