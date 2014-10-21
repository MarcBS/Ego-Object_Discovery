function boxes = getBoxesBING( img_name, W, workingpath )
%RUNBING Interface for running BING Objectness.
%   Runs the BInarized Normed Gradients Objectness measure on set of
%   samples in "img_path".
%%
    img_name = regexp(img_name, '\.', 'split');

    % Format data bounding box structure
    res_img = fileread([workingpath 'Results/BBoxesB2W8MAXBGR/' img_name{1} '.txt']);
    res_img = regexp(res_img, '\n', 'split');
    
    boxes = zeros(W,5);
    for k = 1:W
        boundbox = res_img(k+1);
        boundbox = regexp(boundbox{1}(1:end-1), ', ', 'split');
        boxes(k,5) = str2num(boundbox{1});
        boxes(k,1) = str2num(boundbox{2});
        boxes(k,2) = str2num(boundbox{3});
        boxes(k,3) = str2num(boundbox{4});
        boxes(k,4) = str2num(boundbox{5});
%         boxes(k,1) = str2num(boundbox{2});
%         boxes(k,2) = str2num(boundbox{5});
%         boxes(k,3) = str2num(boundbox{4});
%         boxes(k,4) = str2num(boundbox{3});
    end
    
end

