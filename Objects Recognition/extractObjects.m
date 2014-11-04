function [ objects ] = extractObjects( path_folders, objects, prop_res, objectness, format, workingpath )
%EXTRACTOBJECTS Extracts object candidates and calculates objectness.
%%%%

    W = objectness.W;
    type = objectness.type;
    selsearch_params = objectness.selectiveSearch;
    % type = 'Ferrari' ONLY VALID ON LINUX!
    % type = 'BING' ONLY VALID ON WINDOWS!
    % type = 'MCG' ONLY VALID ON LINUX or MAC!
    % type = 'SelectiveSearch' ???? WINDOWS valid

    %% Extract object candidates and objectness from each of them
    lenImgs = length(objects);
    disp(['Starting extraction of objects from ' num2str(lenImgs) ' images.']);
    
    %%% Pre-extraction for BING objectness
    if(strcmp(type, 'BING'))
        prev_folder = '';
        for i = 1:lenImgs
            fold_path = [path_folders '/' objects(i).folder '/'];
            if(~strcmp(prev_folder, objects(i).folder))
                prev_folder = objects(i).folder;
                runBINGNoValidation(fold_path, format, workingpath, prop_res);
            end
        end
    end
    
    %%% Start extraction image by image
    parfor i = 1:lenImgs
        img_path = [path_folders '/' objects(i).folder '/' objects(i).imgName];
        
        % Extract W objects from this image and their objectness
        if(strcmp(type, 'Ferrari'))
            % Load image
            img = imread(img_path);
            img = imresize(img,[size(img,1)/prop_res size(img,2)/prop_res]);
            boxes = runObjectness(img,W);
        elseif(strcmp(type, 'BING'))
            boxes = getBoxesBING(objects(i).imgName, W, workingpath);
        elseif(strcmp(type, 'MCG'))
            % Load image
            img = imread(img_path);
            img = imresize(img,[size(img,1)/prop_res size(img,2)/prop_res]);
            boxes = runObjectnessMCG(img,W);
        elseif(strcmp(type, 'SelectiveSearch'))
            img = imread(img_path);
            img = imresize(img,[size(img,1)/prop_res size(img,2)/prop_res]);
            boxes = runObjectnessSelectiveSearch(img, W, selsearch_params);
        end
%         boxes = [1 1 size(img, 2) size(img, 1) 1]; % tmp line only for Toy Problem Dataset, uncomment previous!!
        for j = 1:size(boxes,1)
            objects(i).objects(j).ULx = round(boxes(j,1));
            objects(i).objects(j).ULy = round(boxes(j,2));
            objects(i).objects(j).BRx = round(boxes(j,3));
            objects(i).objects(j).BRy = round(boxes(j,4));
            objects(i).objects(j).objScore = boxes(j,5);
            objects(i).objects(j).eventAwareScore = 0;
            objects(i).objects(j).contextAwareScore = 0;
            objects(i).objects(j).label = 0;
        end

        if(mod(i,100) == 0 || lenImgs == i)
            disp(['Extracted objects from ' num2str(i) '/' num2str(lenImgs)]);
            %% TMP LINE, DELETE!!!
%             save(['/Volumes/SHARED HD/Video Summarization Objects/Features/Data MSRC MCG' '/objects.mat'], 'objects');
        end
        %figure,imshow(img),drawBoxes(boxes);
    end

    if(strcmp(type, 'BING'))
        rmdir([workingpath 'Results/BBoxesB2W8MAXBGR'], 's');
    end
    
end

