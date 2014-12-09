function [ boxes ] = runObjectnessMCG( img, W )
%RUNOBJECTNESSMCG Runs the MCG objectness measure on the passed image.
%   Extracts the best W bounding boxes for the img using the Multiscale
%   Combinatorial Grouping objectness measure.

    [candidates_scg, ~] = im2mcg(img,'fast');
    
    count = 0; lenSegm = size(candidates_scg.scores,1);
    W = min(W, lenSegm);
    boxes = zeros(W, 5);
    scores = candidates_scg.scores;
    [scores, p] = sort(scores, 'descend');
    for i = 1:W
        boxes(i,1) = candidates_scg.bboxes(p(i), 2);
        boxes(i,2) = candidates_scg.bboxes(p(i), 1);
        boxes(i,3) = candidates_scg.bboxes(p(i), 4);
        boxes(i,4) = candidates_scg.bboxes(p(i), 3);
        boxes(i,5) = scores(i);
    end

end

