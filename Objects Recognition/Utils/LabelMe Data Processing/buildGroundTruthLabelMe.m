 
%% This script builds a Ground Truth file for the EDUB dataset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

volume_path = '/Volumes/SHARED HD/';

path_folders = [volume_path 'Video Summarization Project Data Sets/EDUB 2015'];
folders = {'Subject1_1/Annotations', 'Subject1_2/Annotations', 'Subject2_1/Annotations', 'Subject2_2/Annotations', ...
    'Subject3_1/Annotations', 'Subject3_2/Annotations', 'Subject4_1/Annotations', 'Subject4_2/Annotations'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXECUTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prepare GT file
imagesGT = struct('folder', [], 'imgName', []);

offset = 0;
nFolders = length(folders);
for i = 1:nFolders

    %% List all .xml files with annotations
    disp('# LISTING all annotations files');
    annotations = dir([path_folders '/' folders{i} '/*.xml']);

    %% Check annName and objName are the same
    lenAnn = length(annotations);
    countAnn = 1;
    disp('# READING OBJECTS...');
    for j = 1:lenAnn
        annName = regexp(annotations(j).name, '\.', 'split');
        imagesGT(j+offset).imgName = annName;
        imagesGT(j+offset).folder = folders{i};
        
        %% Read xml
        xmlContent = fileread([path_folders '/' folders{i} '/' annotations(j).name]);
        objs = regexp(xmlContent, '<object>', 'split');
        
        %% Insert ground truth into object struct
        imagesGT(j+offset).ground_truth = struct('name', [], 'pose', [], 'truncated', [], ...
            'difficult', [], 'ULx', [], 'ULy', [], 'BRx', [], 'BRy', []);

        %% For each object
        count_obj = 1;
        for obj = {objs{2:end}}
            %% Get all attributes
            imagesGT(j+offset).ground_truth(count_obj).name = getElementXML(obj{1}, 'name');
            [xmin, ymin, xmax, ymax] = getObjectData(obj{1});
            imagesGT(j+offset).ground_truth(count_obj).ULx = xmin;
            imagesGT(j+offset).ground_truth(count_obj).ULy = ymin;
            imagesGT(j+offset).ground_truth(count_obj).BRx = xmax;
            imagesGT(j+offset).ground_truth(count_obj).BRy = ymax;
            imagesGT(j+offset).ground_truth(count_obj).occluded = str2num(getElementXML(obj{1}, 'occluded'));

            count_obj = count_obj + 1;
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
save('GT.mat', 'imagesGT');

disp('Ground Truth building finished.');
