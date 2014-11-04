
%% Gets useful information from the objects stored in the given path

% path_features = 'D:\Video Summarization Objects\Features\Data PASCAL_07 GT';
path_features = 'D:\Video Summarization Objects\Features\Data CIFAR-10 GT';

get_difficult = false;

%% Load Objects
load([path_features '/objects.mat']);


nImages = length(objects);
nObjects = 0;
nDifficult = 0;
labels = {};
%% Count different info
obj_count = 1;
for img = objects
    nObjects = nObjects + length(img.objects);
    for obj = img.objects
        labels{obj_count} = obj.trueLabel;
        if(get_difficult)
            nDifficult = nDifficult + obj.difficult;
        end
        obj_count = obj_count+1;
    end
end

% Sort classes by their number of instances
un_labels = unique(labels);
n = zeros(length(un_labels), 1);
for iy = 1:length(un_labels)
  n(iy) = length(find(strcmp(un_labels{iy}, labels)));
end
[label_counts, p] = sort(n, 'descend');
labels = {un_labels{p}};


%% Display information
disp(['Number of images: ' num2str(nImages) '.']);
disp(['Number of objects: ' num2str(nObjects) ', ' num2str(nObjects/nImages) ' per image on average.']);
if(get_difficult)
    disp(['Number of difficult objects: ' num2str(nDifficult) ', ' num2str(nDifficult/nObjects*100) '%.']);
end
disp('Different classes found and their counts:');
for i = 1:length(labels)
   disp(sprintf([labels{i} ': \t' num2str(label_counts(i))]));
end



