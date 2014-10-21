%% This scripts creates a summary image of NxM equally distributed pictures
% from a single SenseCam dataset.

% % To show or not to show blank margins arround each shown image
% margins = true;
% size_margins = 5;

%% Number of images
N = 2; % rows
M = 10; % columns

%% Size of images (pixels)
x_size = 300;
y_size = x_size*0.75;

%% Initial offsets
ini_off = 3; % added to the first image
end_off = 1; % substracted to the last image

%% Sets path
volume_path = 'D:';
% volume_path = '/Volumes/SHARED HD';
% path_folders = [volume_path '/Documentos/Vicon Revue Data'];
path_folders = 'D:\Documentos\Dropbox\Video Summarization Project\Results\Object Recognition\Object Discovery Visualitzation\f)\Harder Instances_iter44\1_tvmonitor';
% folder = 'Perina Short Dataset';
folder = 'Cluster_Samples';
% format = '.JPG'; 
format = '.jpg';

%% Gets pictures
result_img = uint8(zeros(y_size*N, x_size*M, 3));
pictures = dir([path_folders '/' folder '/*' format]);
nImg = N*M;
% Chooses N*M equidistant images
imgInd = linspace(1+ini_off, length(pictures)-end_off, nImg);


%% Inserts the images into the result figure
x = 1; y = 1;
for i = 1:nImg
    % Load image
    this_img = imread([path_folders '/' folder '/' pictures(round(imgInd(i))).name]);
    
    % Show or not blank margins arround the image
%     if(~margins)
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
    
    % Insert picture into result figure
    result_img((y_size*(y-1)+1):(y_size*y), (x_size*(x-1)+1):(x_size*x), :) = this_img;
    
    % Reset indices
    if(mod(x,10) == 0)
        y = y+1;
        x = 0;
    end
    x = x+1;
end

%% Store result
imwrite(result_img, 'Summary_Image3.jpg');
