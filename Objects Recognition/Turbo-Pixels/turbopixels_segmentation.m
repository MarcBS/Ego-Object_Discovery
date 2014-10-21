% Runs the superpixel code on a set of images and stores the results

%% Parameters
volume_path = 'D:';
% volume_path = '/Volumes/SHARED HD';

nTurboPixels = 50;
prop_res = 4;
feat_path = [volume_path '/Video Summarization Objects/Features/Data SenseCam 0BC25B01'];
path_folders = [volume_path '/Documentos/Vicon Revue Data'];
folders = {'0BC25B01-7420-DD20-A1C8-3B2BD6C87CB0', '16F8AB43-5CE7-08B0-FD11-BA1E372425AB', ...
    '2E1048A6ECT', '5FA739A3-AAC4-E84B-F7CB-2179AD879AE3', '6FD1B048-A2F2-4CAB-1EFE-266503F59CD3' ...
    '819DC958-7BFE-DCC8-C792-B54B9641AA75', '8B6E4826-77F5-66BF-FCBA-4054D0E84B0B', ...
    'A06514ED-60B5-BF77-5549-2ED885FD7788', 'B07CCAA9-FEBF-E8F3-B637-B021D652CA48', ...
    'D3B168F2-40C8-7BAB-5DA2-4577404BAC7A'};
format = '.JPG';

%% Change path
cd '../../Turbo-Pixels'
addpath('lsmlib');

%% Load objects
disp('# LOADING OBJECTS FILE...');
load([feat_path '/objects.mat']);

lenObj = length(objects);
disp('# STARTING TURBO-PIXELS SEGMENTATION...');
tic
for j = 1:lenObj
    %% Load image
    img_path = [path_folders '/' objects(j).folder '/' objects(j).imgName];
    img = im2double(imread(img_path));
    img = imresize(img, round([size(img,1)/prop_res size(img,2)/prop_res]));
    [phi,boundary,disp_img,indexed] = superpixels2(img, nTurboPixels);
%     imagesc(disp_img);

    %% Segment into turbo-pixels
    % It extracts the minimum rectangular window surrounding each superpixel
    nSuper = length(unique(indexed));
    for i = 1:nSuper
        [y, x] = find(indexed==i);
        maxX = max(x);
        maxY = max(y);
        minX = min(x);
        minY = min(y);
        superpixels(j, i).ULx = minX;
        superpixels(j, i).ULy = minY;
        superpixels(j, i).BRx = maxX;
        superpixels(j, i).BRy = maxY;
        superpixels(j, i).center = [round((maxY+minY)/2) round((maxX+minX)/2)];
%         rectangle('Position', [minX minY maxX-minX maxY-minY]);
    end
    
    %% Show progress
    if(mod(j,10) == 0)
        disp(['Segmented ' num2str(j) '/' num2str(lenObj) ' images.']);
        toc
    end
end
disp(['Segmented ' num2str(j) '/' num2str(lenObj) ' images.']);

%% Store results
save([feat_path '/superpixels.mat'], 'superpixels');
cd '../Objects Recognition/Turbo-Pixels'
