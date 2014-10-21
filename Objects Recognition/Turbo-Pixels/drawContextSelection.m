function drawContextSelection( i, j, objects, superpixels, context_selection, path_folders, prop_res )

    %% Load image
    img_path = [path_folders '/' objects(i).folder '/' objects(i).imgName];
    img = im2double(imread(img_path));
    img = imresize(img, round([size(img,1)/prop_res size(img,2)/prop_res]));
    imshow(img);
    hold on;
    
    %% Load object candidate
    obj = objects(i).objects(j);
    center = [(obj.ULy + obj.BRy)/2 (obj.ULx + obj.BRx)/2];
    plot(center(2),center(1),'b+','MarkerSize',10);
    rectangle('Position', [obj.ULx obj.ULy obj.BRx-obj.ULx obj.BRy-obj.ULy], 'EdgeColor', 'blue');
    
    %% Load context superpixels
    top = context_selection(i,j).top;
    bottom = context_selection(i,j).bottom;
    nTop = length(top);
    nBot = length(bottom);
    for k = 1:nTop
        sup = superpixels(i, top(k).idx);
        plot(sup.center(2),sup.center(1),'r+','MarkerSize',6);
        rectangle('Position', [sup.ULx sup.ULy sup.BRx-sup.ULx sup.BRy-sup.ULy], 'EdgeColor', 'red');
    end
    for k = 1:nBot
        sup = superpixels(i, bottom(k).idx);
        plot(sup.center(2),sup.center(1),'g+','MarkerSize',6);
        rectangle('Position', [sup.ULx sup.ULy sup.BRx-sup.ULx sup.BRy-sup.ULy], 'EdgeColor', 'green');
    end

end

