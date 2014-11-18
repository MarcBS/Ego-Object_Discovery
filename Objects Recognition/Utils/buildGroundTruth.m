 
%% This script builds a Ground Truth file with all the true labels assigned
%   to the "objects" structure.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('LabelMe Data Processing');

volume_path = '/Volumes/SHARED HD/';
% volume_path = 'D:/';

% path_folders = [volume_path 'Video Summarization Project Data Sets/PASCAL'];
% folders = { 'VOCtrainval_06-Nov-2007\VOCdevkit\VOC2007\Annotations', ...
%             'VOCtest_06-Nov-2007\VOCdevkit\VOC2007\Annotations'};
% path_features = {[volume_path 'Video Summarization Objects/Features/Data PASCAL_07']};

path_folders = [volume_path '/Video Summarization Project Data Sets/PASCAL_12/VOCdevkit/VOC2012/'];
% path_folders = [volume_path '/Video Summarization Project Data Sets/MSRC'];
folders = {'Annotations'};
path_features = {[volume_path 'Video Summarization Objects/Features/Data PASCAL_12 Ferrari']};
% path_features = {[volume_path 'Video Summarization Objects/Features/Data MSRC Ferrari']};

threshold_detection = 0.5;

% selects if the annotation files are from PASCAL or from the custom labeling
% app.
annoType = 'PASCAL'; % 'PASCAL' or 'CUSTOM' or 'MSRC' or 'LABELME'

% list of allowed GT labels
limitAllowed = false;
allowed = {'hand', 'mobilephone', 'tvmonitor', 'person'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXECUTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load objects file
disp('# LOADING OBJECTS file...');
load([path_features{1} '/objects.mat']);
offset = 0;

nFolders = length(folders);
for i = 1:nFolders
%     %% Load objects file
%     disp(['# LOADING OBJECTS file ' num2str(i) '/' num2str(nFolders) '...']);
%     load([path_features{i} '/objects.mat']);

    %% List all .xml files with annotations
    disp('# LISTING all annotations files');
    annotations = dir([path_folders '/' folders{i} '/*.xml']);

    %% Check annName and objName are the same
    lenAnn = length(annotations);
    countAnn = 1;
    disp('# READING OBJECTS...');
    for j = 1:lenAnn
        objName = regexp(objects(j+offset).imgName, '\.', 'split');
        if(strcmp(annoType, 'CUSTOM'))
            annName = {['img' num2str(str2num(objName{1})+1)]};
            
            %% Read xml
            xmlContent = fileread([path_folders '/' folders{i} '/' annName{1} '.xml']);
            objs = regexp(xmlContent, '<object>', 'split');
        elseif(strcmp(annoType, 'PASCAL') || strcmp(annoType, 'MSRC') || strcmp(annoType, 'LABELME'))
            annName = regexp(annotations(j).name, '\.', 'split');
            
            %% Read xml
            xmlContent = fileread([path_folders '/' folders{i} '/' annotations(j).name]);
            objs = regexp(xmlContent, '<object>', 'split');
        end
        
        % if both names are the same
        if(strcmp(objName{1}, annName{1}) || strcmp(annoType, 'CUSTOM'))
            %% Insert ground truth into object struct
            objects(j+offset).ground_truth = struct('name', [], 'pose', [], 'truncated', [], ...
                'difficult', [], 'ULx', [], 'ULy', [], 'BRx', [], 'BRy', []);

            %% Initialize object candidates
            nObjs = length(objects(j+offset).objects);
            for k = 1:nObjs
                objects(j+offset).objects(k).OS = zeros(1, length({objs{2:end}}));
                objects(j+offset).objects(k).trueLabel = 'No Object';
                objects(j+offset).objects(k).trueLabelId = [];
            end
            
            %% For each object
            count_obj = 1;
            for obj = {objs{2:end}}
                %% Get all attributes
                objects(j+offset).ground_truth(count_obj).name = getElementXML(obj{1}, 'name');
                if(strcmp(annoType, 'LABELME')) % different annotation if comes from LabelMe
                    [xmin, ymin, xmax, ymax] = getObjectData(obj{1});
                    objects(j+offset).ground_truth(count_obj).ULx = xmin;
                    objects(j+offset).ground_truth(count_obj).ULy = ymin;
                    objects(j+offset).ground_truth(count_obj).BRx = xmax;
                    objects(j+offset).ground_truth(count_obj).BRy = ymax;
                    objects(j+offset).ground_truth(count_obj).occluded = str2num(getElementXML(obj{1}, 'occluded'));
                else
                    objects(j+offset).ground_truth(count_obj).ULx = str2num(getElementXML(obj{1}, 'xmin'));
                    objects(j+offset).ground_truth(count_obj).ULy = str2num(getElementXML(obj{1}, 'ymin'));
                    objects(j+offset).ground_truth(count_obj).BRx = str2num(getElementXML(obj{1}, 'xmax'));
                    objects(j+offset).ground_truth(count_obj).BRy = str2num(getElementXML(obj{1}, 'ymax'));
                    if(strcmp(annoType, 'PASCAL'))
                        objects(j+offset).ground_truth(count_obj).pose = getElementXML(obj{1}, 'pose');
                        objects(j+offset).ground_truth(count_obj).truncated = str2num(getElementXML(obj{1}, 'truncated'));
                        objects(j+offset).ground_truth(count_obj).difficult = str2num(getElementXML(obj{1}, 'difficult'));
                    end
                end
                
                %% Check if any object in objects(j).objects matches 
                %  with the ground_truth for assign them the true label!
                GT = objects(j+offset).ground_truth(count_obj);
                GT.height = (GT.BRy - GT.ULy + 1);
                GT.width = (GT.BRx - GT.ULx + 1);
                GT.area = GT.height * GT.width;
                
                %% Check for each object candidate, if it fits the current true object
                count_candidate = 1;
                for w = objects(j+offset).objects
                    
                    % Check area and intersection on current window "w"
                    w.height = (w.BRy - w.ULy + 1);
                    w.width = (w.BRx - w.ULx + 1);
                    w.area = w.height * w.width;

                    % Check intersection
                    count_intersect = rectint([GT.ULy, GT.ULx, GT.height, GT.width], [w.ULy, w.ULx, w.height, w.width]);
                    
                    % Calculate overlap score
                    OS = count_intersect / (GT.area + w.area - count_intersect);
                    
                    if(OS > threshold_detection) % object detected!
                        label = getElementXML(obj{1}, 'name');
                        % If OS bigger than previous, then assign this
                        if(max(w.OS) < OS && (~limitAllowed || sum(ismember(allowed, label))))
                            w.trueLabel = label;
                            w.trueLabelId = count_obj;
                        end
                    end
                    w.OS(count_obj) = OS;
                    
                    % Store w object
                    objects(j+offset).objects(count_candidate).OS = w.OS;
                    objects(j+offset).objects(count_candidate).trueLabel = w.trueLabel;
                    objects(j+offset).objects(count_candidate).trueLabelId = w.trueLabelId;
                    
                    count_candidate = count_candidate + 1;
                end
                
                count_obj = count_obj + 1;
            end
            
        %% Error, objName != annName    
        else
            disp(['>>> ERROR ' num2str(j) ': objName ' objName{1} ', annName ' annName{1}]);
        end
        
        %% Check progress of annotations readed
        if(mod(countAnn, 100) == 0 || countAnn == lenAnn)
            disp(['Annotation files read: ' num2str(countAnn) '/' num2str(lenAnn)]);
        end
        countAnn = countAnn+1;
    end 
    disp(' ');
    
    offset = offset+lenAnn;
    
%     %% Save objects again
%     save([path_features{i} '/objects.mat'], 'objects');
end

%% Save objects
save([path_features{1} '/objects.mat'], 'objects');

disp('Ground Truth building finished.');
