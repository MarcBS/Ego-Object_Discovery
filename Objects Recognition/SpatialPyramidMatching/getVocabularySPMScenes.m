
%% Selects a random subset of SIFT features from all the scnes and 
%   applies clustering over them to generate a common vocabulary.
addpath('../../K_Means;../Utils')

vocabLen = 200;
nSamples = 100000; % set to 100.000 when all images available?
nSampPerImage = 400; % set to 5 when all images available
feat_path = 'F:/Object Discovery Data\Video Summarization Objects\Features\Data Narrative_Dataset Ferrari';
SIFT_len = 128;

% Variable for storing all the chosen SIFT samples
randSamples = zeros(nSamples, SIFT_len);

% Load image folders
imgs = dir([feat_path '/img*']);
nImgs = length(imgs);

% Select random images to sample
imgs_idx = randsample(1:nImgs, nImgs);

% Get nSampPerImage objects from each image
i = 1; count = 0; max_count = nSamples/nSampPerImage;
%% Loop over images
while count < max_count
    name_img = imgs(imgs_idx(i)).name;
    if(strcmp(name_img(1:3), 'img')) % if it is a valid image
        load([feat_path '/' name_img '/scn.mat']);
        nSIFT = size(scn_feat.SIFT_feat,1) * size(scn_feat.SIFT_feat,2);
        if(nSIFT >= nSampPerImage) % if enough SIFT descriptors for the object
            SIFT_idx = randsample(1:nSIFT, nSampPerImage);

            %% Loop over SIFT descriptors
            count_SIFT = 0;
            for k = SIFT_idx
                col = mod(k,size(scn_feat.SIFT_feat,2));
                if(col==0) col = size(scn_feat.SIFT_feat,2); end
                row = (k - col)/size(scn_feat.SIFT_feat,2)+1;
                % Get selected SIFT
                randSamples(count*nSampPerImage + count_SIFT + 1, :) = scn_feat.SIFT_feat(row,col,:);
                count_SIFT = count_SIFT +1;
            end
        end
        count = count +1;
    end
    i = i+1;
end

%% Kmeans with randSamples to create a vocabulary represented by the centroids
[randSamples, V_min_normS, V_max_normS] = normalize(randSamples);
[~, VS] = litekmeans(randSamples', vocabLen); VS = VS';

%% Save result
fold_name = regexp(feat_path, '/', 'split'); fold_name = fold_name{end};
save(['../Vocabulary/' fold_name '/min_normS.mat'], 'V_min_normS');
save(['../Vocabulary/' fold_name '/max_normS.mat'], 'V_max_normS');
save(['../Vocabulary/' fold_name '/vocabularyS.mat'], 'VS');
