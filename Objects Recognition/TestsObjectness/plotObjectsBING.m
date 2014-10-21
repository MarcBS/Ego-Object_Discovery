%% Initial parameters

% Location where all the tests results will be stored
tests_path = '../../../../../../Video Summarization Tests';

show_N_imgs = 100; % number of images that will be showed
show_N_windows = 5  ; % number of windows shown per image
colours = {'r';'g';'b';'c';'y'};
W = 50; % number of object windows extracted for each image using the objectness measure

store_folder = [tests_path '/TestsObjectness/' 'Images_PASCAL_BING_trainSet'];

%%%% Folder Parsing Parameters

path_results = 'D:\Video Summarization Project Data Sets\PASCAL_BING\WkDir\Results\BBoxesB2W8MAXBGR';
path_folders = 'D:\Video Summarization Project Data Sets\PASCAL_BING\Train Data\JPEGImages';

%format = '.JPG'; 
format = '.jpg';


%% Get list of images
listImages = dir([path_folders '/*' format]);


%% Show objects on images
instances_per_img = W/show_N_windows;
% Go through each image
count = 1;
for i = 1:show_N_imgs
    
    name = regexp(listImages(count).name, '\.', 'split');
    % Checks if the current image has a .txt result file
    while(~(exist([path_results '/' name{1} '.txt'], 'file') == 2))
        count = count+1;
        name = regexp(listImages(count).name, '\.', 'split');
    end
    
    % Format data in results file
    res_img = fileread([path_results '/' name{1} '.txt']);
    res_img = regexp(res_img, '\n', 'split');

    % Read image
    img = [path_folders '/' listImages(count).name];
    img = imread(img);

    for j = 1:instances_per_img
        img_ = img;
        objs = ((j-1)*show_N_windows+1):j*show_N_windows;
        f = figure; imshow(img_);
        count2 = 1;
        for k = objs
            boundbox = res_img(k+1);
            boundbox = regexp(boundbox{1}(1:end-1), ', ', 'split');
            obj.objScore = str2num(boundbox{1});
            obj.ULx = str2num(boundbox{2});
            obj.ULy = str2num(boundbox{3});
            obj.BRx = str2num(boundbox{4});
            obj.BRy = str2num(boundbox{5});

            %# draw a rectangle
            rectangle('Position',[obj.ULx obj.ULy obj.BRx-obj.ULx obj.BRy-obj.ULy], 'LineWidth',2, 'EdgeColor', colours{count2});
            text(obj.ULx+5, obj.ULy+10, num2str(obj.objScore), 'EdgeColor', colours{count2}, 'Color', colours{count2});
            count2 = count2+1;
        end
        saveas(f, [store_folder '/' name{1} '_' num2str(j) '.jpg'], 'jpg');
        close(gcf);
    end
    count = count+1;
end

