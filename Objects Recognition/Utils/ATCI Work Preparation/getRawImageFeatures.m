function [ features ] = getRawImageFeatures( objects, indices, scale_img, path_folders )

    nObjects = size(indices,1);
    features = zeros(nObjects, scale_img(1)*scale_img(2)*3);
    
    %% Go through each object
    lastObj = [];
    count = 1;
    for ind = indices'
        i = ind(1); % image idx
        j = ind(2); % object idx
        obj = objects(i).objects(j);
        img = objects(i);
        
        % If last image not repeated, then reload
        if(isempty(lastObj) || lastObj(1) ~= i)
            obj_img = imread([path_folders '/' img.folder '/' img.imgName]); % WINDOWS Y MAC
        end
        this_obj_img = obj_img(obj.ULy:obj.BRy, obj.ULx:obj.BRx, :);
        this_obj_img = imresize(this_obj_img, scale_img);
        
        %% Reshape and store raw image into features matrix
        features(count, :) = reshape(this_obj_img, 1, scale_img(1)*scale_img(2)*3);
        
        %% Check progress
        if(mod(count,100) == 0 || size(indices,1) == count)
            disp(['Features extracted from ' num2str(count) '/' num2str(size(indices,1)) ' objects.']);
        end
        
        lastObj = [i j];
        count = count+1;
    end

end

