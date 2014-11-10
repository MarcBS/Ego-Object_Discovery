function [ bboxes ] = runObjectnessSelectiveSearch( img, W, params )
%RUNOBJECTNESSSELECTIVESEARCH Runs the Selective Search objectness measure
%   extracting the desired number of window candidates.

    sigma = params.sigma;
    k = params.k;
    minSize = params.minSize;
    colorType = params.colorType;
    simFunctionHandles = params.simFunctionHandles;
    
    %% Apply Selective Search for each colour space and filter repeated bounding boxes
    boxes = [];
    priority = [];
    for col = colorType
        [b, ~, ~, ~, p] = Image2HierarchicalGrouping(img, sigma, k, minSize, col{1}, simFunctionHandles(:));
        boxes = [boxes; b];
        priority = [priority; p];
    end
    [boxes ind] = BoxRemoveDuplicates(boxes);
    priority = priority(ind);
    [priority, p] = sort(priority, 'ascend');
    boxes = boxes(p,:);
    
    %% Get final best candidates
    W = min(W, size(boxes,1));
    priority = priority(1:W);
    bboxes = zeros(W, 5);
    for i = 1:W
        bboxes(i,1) = boxes(i,2);
        bboxes(i,2) = boxes(i,1);
        bboxes(i,3) = boxes(i,4);
        bboxes(i,4) = boxes(i,3);
        bboxes(i,5) = (priority(end)-priority(i))/priority(end);
    end
    
end

