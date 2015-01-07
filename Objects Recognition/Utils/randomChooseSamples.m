%% This script simply chooses randomly a set of samples for each of the 
% present classes in the objects structure.


%% Parameters
nSamplesPerClass = 5;

out_name = 'Narrative_Dataset';
% volume_path = 'D:';
volume_path = '/Volumes/SHARED HD';
feat_path = [volume_path '/Video Summarization Objects/Features/Data Narrative_Dataset Ferrari'];
% path_folders = [volume_path '/Documentos/Vicon Revue Data'];
path_folders = [volume_path '/Video Summarization Project Data Sets/Narrative_Dataset'];
prop_res = 1;
load([feat_path '/objects.mat']);


%% Get all classes and all samples from each class
classes = {};
samples = {};
nImages = length(objects);
for i = 1:nImages
    nObjects = length(objects(i).objects);
    for j = 1:nObjects
        lab = objects(i).objects(j).trueLabel;
        ind = find(ismember(classes, lab));
        if(isempty(ind))
            classes = {classes{:}, lab};
            ind = length(classes);
            samples{ind} = [];
        end
        samples{ind} = [samples{ind}; i j];
    end
end

%% Select randomly nSamplesPerClass
nClasses = length(classes);
ind = zeros(nClasses, nSamplesPerClass, 2);
for i = 1:nClasses
    randoms = randsample(1:size(samples{i},1), nSamplesPerClass);
    ind(i,:,:) = samples{i}(randoms, :);
end

%% Save each chosen samples in a folder
folder_out = ['RandomChosenSamples_' out_name];
mkdir(folder_out);
for i = 1:nClasses
    for j = 1:nSamplesPerClass
        i1 = ind(i,j,1);
        i2 = ind(i,j,2);
        img_all = imread([path_folders '/' objects(i1).folder '/' objects(i1).imgName]);
        img_all = imresize(img_all,[size(img_all,1)/prop_res size(img_all,2)/prop_res]);
        obj = objects(i1).objects(i2);
        obj_img = img_all(round(obj.ULy):round(obj.BRy), round(obj.ULx):round(obj.BRx), :);
        imwrite(obj_img, [folder_out '/' classes{i} '_' num2str(j) '.jpg']);
    end
end

disp('Done');
