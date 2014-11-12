%% This function checks if the resulting annotation files from the images
% in the "single" folders have one (good) or more objects (mistake).


% volume_path = '/Volumes/SHARED HD/';
volume_path = 'D:/';

path_imgs = [volume_path 'Video Summarization Project Data Sets/MSRC_not_processed/msrcorid'];
path_result = [volume_path 'Video Summarization Project Data Sets/MSRC'];

folders = {'/aeroplanes/general/'; '/aeroplanes/single/'; '/animals/cows/general/'; ...
    '/animals/cows/single/'; '/animals/sheep/general/'; '/animals/sheep/single/'; ...
    '/benches_and_chairs/'; '/bicycles/general/'; '/bicycles/side view, single/'; ...
    '/birds/general/'; '/birds/single/'; '/buildings/'; '/cars/front view/'; ...
    '/cars/general/'; '/cars/rear view/'; '/cars/side view/'; '/chimneys/'; ...
    '/doors/'; '/flowers/general/'; '/flowers/single/'; '/leaves/'; ...
    '/scenes/countryside/'; '/scenes/urban/'; '/signs/'; '/trees/general/'; ...
    '/trees/single/'; '/windows/'};

are_single = [0 1 0 1 0 1 1 0 1 0 1 1 1 0 1 1 1 0 0 0 0 0 0 0 0 0 0];

format = '.JPG';


%% Get destination folder
path_result_anno = [path_result '/Annotations'];

%% Start search
count = 0;
countWrong = 0;
nFolders = length(folders);
for i = 1:nFolders
    if(are_single(i))
        this_path_imgs = [path_imgs folders{i}];
        files_gt = dir([this_path_imgs '*' format]);
        nFiles = length(files_gt);

        % For each file in this folder
        for j = 1:nFiles
            file_name = regexp(files_gt(j).name, '\.', 'split');
            anno_file = fileread([path_result_anno '/' file_name{1} '.xml']);
            objs = regexp(anno_file, '<object>', 'split');
            if(length(objs)-1 > 1)
                countWrong = countWrong+1;
                disp([folders{i} ' > ' file_name{1}]);
            end
            count = count+1;
        end
    end
end

disp(['Total number of files: ' num2str(count)]);
disp(['Total number of files with more than one element: ' num2str(countWrong)]);

disp('Finished processing images.');

