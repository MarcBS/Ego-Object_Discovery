
%% This script builds a Ground Truth file with all the labeles from the 
    %   PASCAL challenge dataset folders.

path_features = {'D:\Video Summarization Objects\Features\Data PASCAL_07_trainval', ...
    'D:\Video Summarization Objects\Features\Data PASCAL_07_test'};


nFolders = length(folders);
%% Load first objects file for knowing the number of offset images
disp('Loading objects file...');
load([path_features{1} '/objects.mat']);
objects_final = objects;
offset = length(objects_final); 
%% For each other folder, we will insert its information into the first one
for i = 2:nFolders
    disp(['Starting folder ' num2str(i) '/' num2str(nFolders) ' processing...']);
    disp('Loading objects file...');
    load([path_features{i} '/objects.mat']);
    lenObjects = length(objects);
    count_obj = 1;
    for j = 1:lenObjects
        %% Insert basic image info
        objects_final(offset+j).folder = objects(j).folder;
        objects_final(offset+j).imgName = objects(j).imgName;
        objects_final(offset+j).idEvent = objects(j).idEvent;
        objects_final(offset+j).labelEvent = objects(j).labelEvent;
        %% Insert info from each object candidate
        lenSubObjects = length(objects(j).objects);
        for w = 1:lenSubObjects
            objects_final(offset+j).objects(w).ULx = objects(j).objects(w).ULx;
            objects_final(offset+j).objects(w).ULy = objects(j).objects(w).ULy;
            objects_final(offset+j).objects(w).BRx = objects(j).objects(w).BRx;
            objects_final(offset+j).objects(w).BRy = objects(j).objects(w).BRy;
            objects_final(offset+j).objects(w).objScore = objects(j).objects(w).objScore;
            objects_final(offset+j).objects(w).eventAwareScore = objects(j).objects(w).eventAwareScore;
            objects_final(offset+j).objects(w).contextAwareScore = objects(j).objects(w).contextAwareScore;
            objects_final(offset+j).objects(w).label = objects(j).objects(w).label;
            objects_final(offset+j).objects(w).trueLabel = objects(j).objects(w).trueLabel;
            try
                objects_final(offset+j).objects(w).OS = objects(j).objects(w).OS;
                objects_final(offset+j).objects(w).trueLabelId = objects(j).objects(w).trueLabelId;
            catch
                continue
            end
        end
        %% Insert info from each ground truth object
        lenGT = length(objects(j).ground_truth);
        for gt = 1:lenGT
            objects_final(offset+j).ground_truth(gt).name = objects(j).ground_truth(gt).name;
            objects_final(offset+j).ground_truth(gt).pose = objects(j).ground_truth(gt).pose;
            objects_final(offset+j).ground_truth(gt).truncated = objects(j).ground_truth(gt).truncated;
            objects_final(offset+j).ground_truth(gt).difficult = objects(j).ground_truth(gt).difficult;
            objects_final(offset+j).ground_truth(gt).ULx = objects(j).ground_truth(gt).ULx;
            objects_final(offset+j).ground_truth(gt).ULy = objects(j).ground_truth(gt).ULy;
            objects_final(offset+j).ground_truth(gt).BRx = objects(j).ground_truth(gt).BRx;
            objects_final(offset+j).ground_truth(gt).BRy = objects(j).ground_truth(gt).BRy;
        end
        %% Store imgX in new location
        f_name = [path_features{1} '/img' num2str(offset+j)];
        mkdir(f_name);
        for w = 1:lenSubObjects
            source_f = [path_features{i} '/img' num2str(j) '/obj' num2str(w) '.mat'];
            dest_f = [f_name '/obj' num2str(w) '.mat'];
            copyfile(source_f, dest_f);
        end
        
        %% Check progress
        if(mod(count_obj, 10) == 0 || count_obj == lenObjects)
            disp(['Objects processed: ' num2str(count_obj) '/' num2str(lenObjects)]);
        end
        count_obj = count_obj +1;    
    end 
    offset = offset + lenObjects;
end

%% Store new objects structure
clear objects
disp('Storing final objects structure.');
objects = objects_final;
save([path_features{1} '/objects_new.mat'], 'objects');

