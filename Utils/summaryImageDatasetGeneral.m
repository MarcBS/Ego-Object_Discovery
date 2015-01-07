%% This scripts creates a summary image of NxM equally distributed pictures
% from a single SenseCam dataset.

% % To show or not to show blank margins arround each shown image
% margins = true;
% size_margins = 5;

%% Number of images
N = 2; % rows
M = 8; % columns

%% Size of images (pixels)
x_size = 300;
y_size = x_size*0.75;

%% Initial offsets
ini_off = 1; % added to the first image
end_off = 6; % substracted to the last image

%% Sets path
% volume_path = 'D:';
volume_path = '/Volumes/SHARED HD';
path_folders = [volume_path '/Video Summarization Project Data Sets/Narrative_Dataset'];
% path_folders = 'D:\Documentos\Dropbox\Video Summarization Project\Results\Object Recognition\Object Discovery Visualitzation\f)\Harder Instances_iter44\1_tvmonitor';
% folder = 'Perina Short Dataset';
folder = 'Mariella2/JPEGImages';
% format = '.JPG'; 
format = '.jpg';

name_out = 'Mariella';

%% Annotation parameters
anno = 'Mariella2/Annotations';
show_annotations = true;
line_width = 10;
labels = {'lamp', 'aircon', 'cupboard', 'tvmonitor', 'door', 'face', ...
    'person', 'sign', 'hand', 'window', 'building', 'paper', 'bottle', ...
    'glass', 'chair', 'mobilephone', 'car', 'train', 'bycicle', ...
    'motorbike', 'dish'};

%% Gets pictures
result_img = uint8(zeros(y_size*N, x_size*M, 3));
pictures = dir([path_folders '/' folder '/*' format]);
if(show_annotations)
    annotations = dir([path_folders '/' anno '/*.xml']);
    c = colormap(jet);
    close(gcf);
    cols = c(round(linspace(1,size(c,1),length(labels))), :);
end
nImg = N*M;
% Chooses N*M equidistant images
imgInd = round(linspace(1+ini_off, length(pictures)-end_off, nImg));



%% Inserts the images into the result figure
x = 1; y = 1;
for i = 1:nImg
    % Load image
    this_img = imread([path_folders '/' folder '/' pictures(imgInd(i)).name]);
    
    % Show or not blank margins arround the image
%     if(~margins)
        ratio_y = size(this_img,1)/y_size;
        ratio_x = size(this_img,2)/x_size;
        this_img = imresize(this_img, [y_size x_size]);
%     else
%         x_img = size(this_img, 2);
%         y_img = size(this_img, 1);
%         prop = x_img/y_img;
%         im = zeros(y_size, x_size, 3);
%         if(y_img > x_img)
%             this_img = imresize(this_img, [(y_size - size_margins*2) (y_size - size_margins*2)*prop]);
%             im(
%         else
%             this_img = imresize(this_img, [(x_size - size_margins*2)/prop (x_size - size_margins*2)]);
%         end
%     end
    
    % Show objects annotations
    if(show_annotations)
        f = figure; imshow(this_img);
        xmlContent = fileread([path_folders '/' anno '/' annotations(imgInd(i)).name]);
        objs = regexp(xmlContent, '<object>', 'split');
        % For each object annotated in the current image
        for obj = {objs{2:end}}
            obj = obj{1};
            name = regexp(obj, '<name>', 'split');
            name = regexp(name{2}, '</name>', 'split'); name = name{1};
            name_id = find(ismember(labels, name));
            pts = regexp(obj, '<pt>', 'split');
            % For each point in the current image
            first_pt = pts{2}; pts = {pts{2:end}};
            len_pts = length(pts)-1;
            for j = 1:len_pts
                x1 = regexp(pts{j}, '<x>', 'split');
                x1 = regexp(x1{2}, '</x>', 'split'); x1 = str2num(x1{1});
                y1 = regexp(pts{j}, '<y>', 'split');
                y1 = regexp(y1{2}, '</y>', 'split'); y1 = str2num(y1{1});
                x2 = regexp(pts{j+1}, '<x>', 'split');
                x2 = regexp(x2{2}, '</x>', 'split'); x2 = str2num(x2{1});
                y2 = regexp(pts{j+1}, '<y>', 'split');
                y2 = regexp(y2{2}, '</y>', 'split'); y2 = str2num(y2{1});
                X = round([x1 x2]/ratio_x);
                Y = round([y1 y2]/ratio_y);
                line(X, Y, 'LineWidth', line_width, 'Color', cols(name_id, :));
            end
            x1 = regexp(pts{j+1}, '<x>', 'split');
            x1 = regexp(x1{2}, '</x>', 'split'); x1 = str2num(x1{1});
            y1 = regexp(pts{j+1}, '<y>', 'split');
            y1 = regexp(y1{2}, '</y>', 'split'); y1 = str2num(y1{1});
            x2 = regexp(first_pt, '<x>', 'split');
            x2 = regexp(x2{2}, '</x>', 'split'); x2 = str2num(x2{1});
            y2 = regexp(first_pt, '<y>', 'split');
            y2 = regexp(y2{2}, '</y>', 'split'); y2 = str2num(y2{1});
            X = round([x1 x2]/ratio_x);
            Y = round([y1 y2]/ratio_y);
            line(X, Y, 'LineWidth', line_width, 'Color', cols(name_id, :));
        end
        set(gca,'units','normalized','position',[0 0 1 1]); % make sure axis fills entire figure
        print(f, '-r80', '-dtiff', 'tmp.png');
        close(gcf);
        this_img = imread('tmp.png');
    end

    % Insert picture into result figure
    this_img = imresize(this_img, [y_size x_size]);
    result_img((y_size*(y-1)+1):(y_size*y), (x_size*(x-1)+1):(x_size*x), :) = this_img;
    
    % Reset indices
    if(mod(x,M) == 0)
        y = y+1;
        x = 0;
    end
    x = x+1;
end

%% Store result
imwrite(result_img, ['Summary_Image_' name_out '.jpg']);
