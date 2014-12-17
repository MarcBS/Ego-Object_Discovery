
%% Selects a random subset of SIFT features from all the objects and 
%   applies clustering over them to generate a common vocabulary.
addpath('../../K_Means;../Utils')

%% Params
volume_path = '/media/lifelogging';
% volume_path = 'D:';

vocabLen = 200;
nSamples = 100000; % set to 100.000 when all images available?
nSampPerImage = 5; % set to 5 when all images available (10 MSRC)
nSampPerObj = 5; % set to 5 when all images available (20 MSRC)
feat_path = [volume_path '/HDD 2TB/Video Summarization Objects/Features/Data Narrative_Dataset Ferrari'];
SIFT_len = 128;


%% Start execution
% Variable for storing all the chosen SIFT samples
randSamples = zeros(nSamples, SIFT_len);

% Load image folders
imgs = dir([feat_path '/img*']);
nImgs = length(imgs);

% Select random images to sample
imgs_idx = randsample(1:nImgs, nImgs);

% Get nSampPerImage objects from each image
i = 1; count = 0; max_count = nSamples/nSampPerImage/nSampPerObj;
%% Loop over images
while count < max_count
    name_img = imgs(imgs_idx(i)).name;
    if(strcmp(name_img(1:3), 'img')) % if it is a valid image
        objects = dir([feat_path '/' name_img '/obj*']);
        obj_idx = randsample(1:length(objects), length(objects));
        j = 1; count_obj = 0; max_obj = nSampPerImage;
        
        %% Loop over objects
        while count_obj < max_obj
            load([feat_path '/' name_img '/obj' num2str(obj_idx(j)) '.mat']);
            nSIFT = size(obj_feat.SIFT_feat,1) * size(obj_feat.SIFT_feat,2);
            if(nSIFT >= nSampPerObj) % if enough SIFT descriptors for the object
                SIFT_idx = randsample(1:nSIFT, nSampPerObj);

                %% Loop over SIFT descriptors
                count_SIFT = 0;
                for k = SIFT_idx
                    col = mod(k,size(obj_feat.SIFT_feat,2));
                    if(col==0) col = size(obj_feat.SIFT_feat,2); end
                    row = (k - col)/size(obj_feat.SIFT_feat,2)+1;
                    % Get selected SIFT
                    randSamples(count*nSampPerImage*nSampPerObj + count_obj*nSampPerObj + count_SIFT + 1, :) = obj_feat.SIFT_feat(row,col,:);
                    count_SIFT = count_SIFT +1;
                end

                count_obj = count_obj +1;
            end
            j = j+1;
        end
        
        count = count +1;
    end
    i = i+1;
end

%% Kmeans with randSamples to create a vocabulary represented by the centroids
[randSamples, V_min_norm, V_max_norm] = normalize(randSamples);
[~, V] = litekmeans(randSamples', vocabLen); V = V';

%% Save result
fold_name = regexp(feat_path, '/', 'split'); fold_name = fold_name{end};
mkdir(['../Vocabulary/' fold_name]);
save(['../Vocabulary/' fold_name '/min_norm.mat'], 'V_min_norm');
save(['../Vocabulary/' fold_name '/max_norm.mat'], 'V_max_norm');
save(['../Vocabulary/' fold_name '/vocabulary.mat'], 'V');
