
addpath('../../Objectness SelectiveSearch;../../Objectness SelectiveSearch/Dependencies');


%% Read test image
im = imread('D:\Documentos\Vicon Revue Data\0BC25B01-7420-DD20-A1C8-3B2BD6C87CB0\00000015.JPG');
prop_res = 4;
im = imresize(im, [size(im,1)/prop_res size(im,2)/prop_res]);

% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
colorType = colorTypes{:}; % Single color space for demo

% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
simFunctionHandles = simFunctionHandles(:); % Two different merging strategies

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
k = 100; % controls size of segments of initial segmentation.
minSize = k;
sigma = 0.8;


% Perform Selective Search
tic;
[boxes blobIndIm blobBoxes hierarchy, priority] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
toc
[boxes ind] = BoxRemoveDuplicates(boxes);
priority = priority(ind);

% Show boxes
ShowRectsWithinImage(boxes, 5, 5, im);


