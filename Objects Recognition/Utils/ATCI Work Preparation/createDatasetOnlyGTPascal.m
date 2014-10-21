
%% This script builds a new dataset only composed by the Ground Truth 
    %   objects from the PASCAL challenge dataset folders.

path_folders = 'D:\Video Summarization Project Data Sets\PASCAL';
folders = { 'VOCtrainval_06-Nov-2007\VOCdevkit\VOC2007\Annotations', ...
            'VOCtest_06-Nov-2007\VOCdevkit\VOC2007\Annotations'};
path_features = {'D:\Video Summarization Objects\Features\Data PASCAL_07 GT'};

%% Build struct for storing all objects found and their classes
objects = struct('folder', [], 'imgName', [], 'idEvent', [], 'labelEvent', [], 'objects', struct('ULx', [], 'ULy', [], ...
    'BRx', [], 'BRy', [], 'trueLabel', [], 'pose', [], 'truncated', [], 'difficult', [], 'objScore', [], 'eventAwareScore', [], ...
    'features', [], 'label', 0));

%% Go through each folder
offset = 0;
nFolders = length(folders);
for i = 1:nFolders

    %% List all .xml files with annotations
    disp('# LISTING all annotations files');
    annotations = dir([path_folders '/' folders{i} '/*.xml']);

    %% Get all annotation for each image
    lenAnn = length(annotations);
    countAnn = 1;
    disp('# READING OBJECTS...');
    for j = 1:lenAnn
        
        %% Initialize info for this image
        img_name = regexp(annotations(j).name, '\.', 'split');
        folder_split = regexp(folders{i}, '\', 'split');
        objects(j+offset).folder = [folder_split{1} '/' folder_split{2} '/' folder_split{3} '/JPEGImages'];
        objects(j+offset).imgName = [img_name{1} '.jpg'];
        objects(j+offset).idEvent = 1;
        objects(j+offset).labelEvent = 1;
        
        %% Read xml
        xmlContent = fileread([path_folders '/' folders{i} '/' annotations(j).name]);
        objs = regexp(xmlContent, '<object>', 'split');
        % For each object
        count_obj = 1;
        for obj = {objs{2:end}}
            %% Get all attributes
            objects(j+offset).objects(count_obj).trueLabel = getElementXML(obj{1}, 'name');
            objects(j+offset).objects(count_obj).pose = getElementXML(obj{1}, 'pose');
            objects(j+offset).objects(count_obj).truncated = str2num(getElementXML(obj{1}, 'truncated'));
            objects(j+offset).objects(count_obj).difficult = str2num(getElementXML(obj{1}, 'difficult'));
            objects(j+offset).objects(count_obj).ULx = str2num(getElementXML(obj{1}, 'xmin'));
            objects(j+offset).objects(count_obj).ULy = str2num(getElementXML(obj{1}, 'ymin'));
            objects(j+offset).objects(count_obj).BRx = str2num(getElementXML(obj{1}, 'xmax'));
            objects(j+offset).objects(count_obj).BRy = str2num(getElementXML(obj{1}, 'ymax'));
            objects(j+offset).objects(count_obj).objScore = 0;
            objects(j+offset).objects(count_obj).eventAwareScore = 0;
            count_obj = count_obj+1;
        end
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

disp('PASCAL dataset building finished.');