function extractFeatures( objects, feat_params, path_folders, prop_res, feat_path, max_size, features_type, extractionLevel )
%EXTRACTFEATURES Extracts the necessary features for classifying the
% objects on the images.
%   The different kinds of features extracted are the following:
%       > 'original':
%           1) COLOR: Lab colorspace histograms with bLAB bins per channel. (69)
%           2) SHAPE: pHOG with levels = lHOG and #bins = bHOG.
%               (sum from i=0 to lHOG of (  4^i * bHOG  ))
%           3) TEXTURE: Dense SIFT descriptors with width = wSIFT and extracted
%               with a distance of dSIFT between each of them, for a posterior
%               Spatial Pyramid Matching. (128 for each descriptor).
%
%       > 'cnn':
%           1) Convolutional NN features from the second to the last layer
%               of ImageNet network (4096).
%   
%   extractionLevel: describes whether we want to extract the features for 
%       the objects [0 1], the scenes [1 0] or both [1 1].
%
%   objectness: parameters referent to the objectness measure used. 
%       type = 'Ferrari' || 'BING'
%   
%%%%%

    addpath('../PHOG');
    addpath('../SIFTflow/mexDenseSIFT');
    if(strcmp(features_type, 'cnn'))
        caffe_path = '/home/marc/Documents/Caffe/caffe/matlab/caffe';
        addpath(caffe_path);
        cd(caffe_path)
        this_path = pwd;
    end

    bHOG = feat_params.bHOG;
    lHOG = feat_params.lHOG;
    bLAB = feat_params.bLAB;
    wSIFT = feat_params.wSIFT;
    dSIFT = feat_params.dSIFT;
    lenCNN = feat_params.lenCNN;
    
%     objType = objectness.type;

    features_params = struct('bLAB', bLAB, 'wSIFT', wSIFT, 'dSIFT', dSIFT, 'lHOG', lHOG, 'bHOG', bHOG, 'lenCNN', lenCNN);
    save([feat_path '/features_params.mat'], 'features_params');

    nImages = length(objects);
    for i = 1:nImages
        img = objects(i);
        %%%%%
    %     img_all = imread([path_folders '/Datasets/' img.folder '/' img.imgName]); % LINUX
        % WINDOWS & MAC
        try
            img_all = imread([path_folders '/' img.folder{1} '/' img.imgName]); 
        catch
            img_all = imread([path_folders '/' img.folder '/' img.imgName]);
        end
        %%%%%
        
        %% Resize image
        img_all = imresize(img_all,[size(img_all,1)/prop_res size(img_all,2)/prop_res]);
%         if(strcmp(objType, 'Ferrari'))
%             img_all = imresize(img_all,[size(img_all,1)/prop_res size(img_all,2)/prop_res]);
%         elseif(strcmp(objType, 'BING'))
%             max_size = objectness.max_size;
%             height = size(img_all, 1);
%             width = size(img_all, 2);
%             if(height > width)
%                 if(height > max_size)
%                     prop = height/max_size;
%                 end
%             else
%                 if(width > max_size)
%                     prop = width/max_size;
%                 end
%             end
%             img_all = imresize(img_all,[size(img_all,1)/prop size(img_all,2)/prop]);
%         end
        
        mkdir([feat_path '/img' num2str(i)]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %==================================================================
        %%       Extract features from scenes
        %==================================================================
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(extractionLevel(1))
            scn_img = img_all;
            % Load scn_feat if exists
            try
                load([feat_path '/img' num2str(i) '/scn.mat']); % scn_feat
            end
        
            %% EXTRACT ORIGINAL FEATURES
            if(strcmp(features_type, 'original'))
                %% Rescale if bigger than max_size
                s = size(scn_img); prop = 1;
                if(s(1) > max_size && s(1) >= s(2))
                    prop = s(1) / max_size;
                elseif(s(2) > max_size && s(2) > s(1))
                    prop = s(2) / max_size;
                end
                scn_img = imresize(scn_img, round(s(1:2)/prop));

                %% 1) COLOR: LAB
                lab_feat = zeros(1,bLAB*3);
                lab_img = applycform(scn_img, makecform('srgb2lab'));
                for c = 1:3
                    lab_feat((c-1)*bLAB+1:c*bLAB) = imhist(lab_img(:,:,c),bLAB);
                end

                %% 2) SHAPE: pHOG
                if(size(scn_img,1) >= bHOG && size(scn_img,2) >= bHOG)
                    roi = [1;size(scn_img,1);1;size(scn_img,2)]; % Region Of Interest
                    % gets sum from i=0 to lHOG of (  4^i * bHOG  )
                    hog_feat = anna_phog(scn_img, bHOG, 360, lHOG, roi)';
                else
                    s = size(scn_img);
                    tmp_prop = bHOG/min([s(1) s(2)]);
                    tmp_img = imresize(scn_img, round(s(1:2)*tmp_prop));
                    roi = [1;size(tmp_img,1);1;size(tmp_img,2)]; % Region Of Interest
                    % gets sum from i=0 to lHOG of (  4^i * bHOG  )
                    hog_feat = anna_phog(tmp_img, bHOG, 360, lHOG, roi)';
                end

                %% 3) TEXTURE: Dense SIFT descriptors
                if(size(scn_img,1) >= wSIFT && size(scn_img,2) >= wSIFT)
                    sift_feat = mexDenseSIFT(scn_img, wSIFT, dSIFT, true);
                else
                    s = size(scn_img);
                    tmp_prop = wSIFT/min([s(1) s(2)]);
                    tmp_img = imresize(scn_img, round(s(1:2)*tmp_prop));
                    sift_feat = mexDenseSIFT(tmp_img, wSIFT, dSIFT, true);
                end

                %% Store features
                scn_feat.LAB_feat = lab_feat;
                scn_feat.PHOG_feat = hog_feat;
                scn_feat.SIFT_feat = sift_feat;

            %% EXTRACT CNN FEATURES
            elseif(strcmp(features_type, 'cnn'))
                %% Generate and Store features
                [cnn_feat, ~] = matcaffe_demo(scn_img, 0);
                scn_feat.CNN_feat = cnn_feat';
            end


            %% Store the rest of the info
            scn_feat.idImg = i;
            save([feat_path '/img' num2str(i) '/scn.mat'], 'scn_feat');
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %==================================================================
        %%       Extract features from objects
        %==================================================================
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(extractionLevel(2))
            nObjects = length(objects(i).objects);
            for j = 1:nObjects 
                %% Load object image
                obj = objects(i).objects(j);
                obj_img = img_all(round(obj.ULy):round(obj.BRy), round(obj.ULx):round(obj.BRx), :);
                % Load obj_feat if exists
                try
                    load([feat_path '/img' num2str(i) '/obj' num2str(j) '.mat']); % obj_feat
                end

                %% EXTRACT ORIGINAL FEATURES
                if(strcmp(features_type, 'original'))
                    %% Rescale if bigger than max_size
                    s = size(obj_img); prop = 1;
                    if(s(1) > max_size && s(1) >= s(2))
                        prop = s(1) / max_size;
                    elseif(s(2) > max_size && s(2) > s(1))
                        prop = s(2) / max_size;
                    end
                    obj_img = imresize(obj_img, round(s(1:2)/prop));

                    %% 1) COLOR: LAB
                    lab_feat = zeros(1,bLAB*3);
                    lab_img = applycform(obj_img, makecform('srgb2lab'));
                    for c = 1:3
                        lab_feat((c-1)*bLAB+1:c*bLAB) = imhist(lab_img(:,:,c),bLAB);
                    end

                    %% 2) SHAPE: pHOG
                    if(size(obj_img,1) >= bHOG && size(obj_img,2) >= bHOG)
                        roi = [1;size(obj_img,1);1;size(obj_img,2)]; % Region Of Interest
                        % gets sum from i=0 to lHOG of (  4^i * bHOG  )
                        hog_feat = anna_phog(obj_img, bHOG, 360, lHOG, roi)';
                    else
                        s = size(obj_img);
                        tmp_prop = bHOG/min([s(1) s(2)]);
                        tmp_img = imresize(obj_img, round(s(1:2)*tmp_prop));
                        roi = [1;size(tmp_img,1);1;size(tmp_img,2)]; % Region Of Interest
                        % gets sum from i=0 to lHOG of (  4^i * bHOG  )
                        hog_feat = anna_phog(tmp_img, bHOG, 360, lHOG, roi)';
                    end

                    %% 3) TEXTURE: Dense SIFT descriptors
                    if(size(obj_img,1) >= wSIFT && size(obj_img,2) >= wSIFT)
                        sift_feat = mexDenseSIFT(obj_img, wSIFT, dSIFT, true);
                    else
                        s = size(obj_img);
                        tmp_prop = wSIFT/min([s(1) s(2)]);
                        tmp_img = imresize(obj_img, round(s(1:2)*tmp_prop));
                        sift_feat = mexDenseSIFT(tmp_img, wSIFT, dSIFT, true);
                    end

                    %% Store features
                    obj_feat.LAB_feat = lab_feat;
                    obj_feat.PHOG_feat = hog_feat;
                    obj_feat.SIFT_feat = sift_feat;

                %% EXTRACT CNN FEATURES
                elseif(strcmp(features_type, 'cnn'))
                    %% Generate and Store features
                    [cnn_feat, ~] = matcaffe_demo(obj_img, 0);
                    obj_feat.CNN_feat = cnn_feat';
                end

                %% Store the rest of the info
                obj_feat.idImg = i;
                obj_feat.idObj = j;
                save([feat_path '/img' num2str(i) '/obj' num2str(j) '.mat'], 'obj_feat');

            end
        end
            
        if(mod(i,10) == 0 || nImages == i)
            disp(['Features extracted from ' num2str(i) '/' num2str(nImages) ' images.']);
        end
    end

    
    if(strcmp(features_type, 'cnn'))
        cd(this_path)
    end
    
end

