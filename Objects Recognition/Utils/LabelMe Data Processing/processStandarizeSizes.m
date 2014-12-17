%% This file is used to standarize the sizes of all the samples labeled
% in LabelMe

%% Parameters
addpath('..');
volume_path = '/Volumes/Shared HD/';

src_path = [volume_path 'Video Summarization Project Data Sets/Narrative_Dataset_Original'];
dst_path = [volume_path 'Video Summarization Project Data Sets/Narrative_Dataset'];

% must have 'Annotations' and 'JPEGImages' folders inside
folders = {'Petia1', 'Petia2', 'Maya1', 'Maya2', ...
    'Estefania1', 'Estefania2', 'Mariella1', 'Mariella2'};
format = '.jpg';
max_stand_size = 512;

%% Start processing
for f = folders
    % Create folders result dir
    mkdir([dst_path '/' f{1} '/Annotations']);
    mkdir([dst_path '/' f{1} '/JPEGImages']);
    
    % Modify each image in the source and store in the destination
    list_imgs = dir([src_path '/' f{1} '/JPEGImages/*' format]);
    nImages = length(list_imgs);
    for i = 1:nImages
        name = regexp(list_imgs(i).name, '\.', 'split'); name = name{1};
        % Read source image and annotation
        anno = fileread([src_path '/' f{1} '/Annotations/' name '.xml']);
        img = imread([src_path '/' f{1} '/JPEGImages/' list_imgs(i).name]);
        
        % Check size to resize
        [height, width, ~] = size(img);
        v = max(height, width);
        prop_res = max_stand_size/v;
        
        % Create destination image and annotation
        anno_dst = fopen([dst_path '/' f{1} '/Annotations/' name '.xml'], 'w');
        writeHeading( anno_dst, f, [name format] );
        img = imresize(img, [round(height*prop_res), round(width*prop_res)]);
        imwrite(img, [dst_path '/' f{1} '/JPEGImages/' list_imgs(i).name]);
        
        % Read all objects in annotation file
        objs = regexp(anno, '<object>', 'split'); 
        objs = {objs{2:end}};
        nObjs = length(objs);
        for j = 1:nObjs
            % Continue if it is not a deleted object
            if(~str2num(getElementXML(objs{j}, 'deleted')))
                writeObject( anno_dst, objs{j}, prop_res );
            end
        end
        
        % Close .xml file
        fprintf(anno_dst, '</annotations>\n');
        fclose(anno_dst);
        
        if(mod(i,100)==0 || i == nImages)
            disp(['Processed ' num2str(i) '/' num2str(nImages) ' images from folder ' f{1} '.']);
        end
    end
end
