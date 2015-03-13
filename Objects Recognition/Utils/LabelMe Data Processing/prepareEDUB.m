%%%%%%%%%%%%%%%%
%
%% This script prepares the ELUB dataset for publication.
%
%%%%%%%%%%%%%%%%

title_result = 'EDUB 2015';
title_original = 'Narrative_Dataset';
dir_original = '/Volumes/SHARED HD/Video Summarization Project Data Sets/';

filter_hsize = 12;
filter_sigma = 30;
square_delete = filter_hsize/2;

%%%%%%%%
mkdir([dir_original title_result]);

original_folders = dir([dir_original title_original]);
original_folders = original_folders(3:end);

%% Get Name ---> SubjectX equivalences
tmp_original_names = {};
count = [];
tmp_result_names = {};
original_names = {};
result_names = {};
for i = 1:length(original_folders)
    name_num = original_folders(i).name;
    name = name_num(1:end-1);
    pos = ismember(tmp_original_names,name);
    if(~sum(pos))
        tmp_original_names = {tmp_original_names{:} name};
        tmp_result_names = {tmp_result_names{:} ['Subject' num2str(length(tmp_result_names)+1)]};
        count = [count 0];
        pos = zeros(1,length(tmp_result_names));
        pos(length(tmp_result_names)) = 1;
    end
    name = tmp_result_names{find(pos)};
    num_folders = count(find(pos))+1;
    count(find(pos)) = num_folders;
    name = [name '_' num2str(num_folders)];
    
    original_names{i} = original_folders(i).name;
    result_names{i} = name;
end

%% Copy and edit Dataset info
% prepare face detector
faceDetector = vision.CascadeObjectDetector;
% prepare blurring filter
filter = fspecial('gaussian', filter_hsize, filter_sigma);
for i = 1:length(original_names)
    orig_fold = [dir_original title_original '/' original_names{i}];
    res_fold = [dir_original title_result '/' result_names{i}];
    mkdir(res_fold);
    mkdir([res_fold '/Annotations']);
    mkdir([res_fold '/JPEGImages']);
    
    %% Anonimize Annotation files
    anno = dir([orig_fold '/Annotations/*.xml']);
    for j = 1:length(anno)
        aname = anno(j).name;
        anno_text = fileread([orig_fold '/Annotations/' aname]);
        
        anno_text = regexp(anno_text, original_names{i}, 'split');
        anno_text = [anno_text{1} result_names{i} anno_text{2}];
        
        anno_res = fopen([res_fold '/Annotations/' aname], 'w');
        fprintf(anno_res, anno_text);
        fclose(anno_res);
    end
    
    %% Anonimize Appearing faces
    imgs_aux = dir([orig_fold '/JPEGImages/*.jpg']);
    nImgs = 0;
    for j = 1:length(imgs_aux)
        if(imgs_aux(j).name(1) ~= '.')
            imgs(nImgs+1) = imgs_aux(j);
            nImgs = nImgs+1;
        end
    end
    for j = 1:nImgs
        iname = imgs(j).name;
        img = imread([orig_fold '/JPEGImages/' iname]);
        bboxes = step(faceDetector, img);
        % Blurr all faces detected
        if(~isempty(bboxes))
            for box = bboxes'
                face = img(box(2):box(2)+box(4), box(1):box(1)+box(3),:);
                face = imfilter(face,filter);
                img(box(2)+square_delete:box(2)+box(4)-square_delete, box(1)+square_delete:box(1)+box(3)-square_delete,:) = face(1+square_delete:end-square_delete, 1+square_delete:end-square_delete,:);
            end
        end
        imwrite(img, [res_fold '/JPEGImages/' iname]);
        % Show progress
        if(mod(j, 50) == 0 || j == nImgs)
            disp(['Processed ' num2str(j) '/' num2str(nImgs) ' folder ' num2str(i) '/' num2str(length(original_names)) '.']);
        end
    end
    
end

disp('Done');