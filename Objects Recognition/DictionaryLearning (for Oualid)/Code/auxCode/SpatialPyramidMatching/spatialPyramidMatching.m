function [ pyramid ] = spatialPyramidMatching( SIFT_feat, V, min_norm, max_norm, L )
%SPATIALPYRAMIDMATCHING Calculates SPM histograms given a set of SIFTs and
% a vocabulary.
%   Extracts the histograms of Spatial Pyramid Matchings corresponding to
%   the given vocabulary "V" and using the number of levels defined by "L".

    %% Store positions for each vector
    SIFT_pos = zeros(size(SIFT_feat,1)*size(SIFT_feat,2), 2);
    count = 1;
    for i = 1:size(SIFT_feat,1)
        for j = 1:size(SIFT_feat,2)
            SIFT_pos(count,:) = [i j];
            count = count+1;
        end
    end

    %% Put all SIFT vectors in a matrix (row-wise)
    SIFT_feat = reshape(SIFT_feat,size(SIFT_feat,1)*size(SIFT_feat,2),size(SIFT_feat,3));

    %% Computes distances between SIFT features and vocabulary and takes the
    % closest for each of them
    [SIFT_feat, ~, ~] = normalize(double(SIFT_feat), min_norm, max_norm);
    dists = pdist2(SIFT_feat, V, 'euclidean');
    [~, m_channels] = min(dists(:,:),[],2);
    
    
    %% Starts to Calculate Spatial Pyramid Matching
    MAX = SIFT_pos(end,:)+1;
    pyramidLevels = L+1; % pyramid levels
    dictionarySize = size(V,1); % dictionary size
    binsHigh = 2^L; % number of maximum bins
    
    %% compute histogram at the finest level
    pyramid_cell = cell(pyramidLevels,1);
    pyramid_cell{1} = zeros(binsHigh, binsHigh, dictionarySize);
    
    for i=1:binsHigh
        for j=1:binsHigh
            
            % find the coordinates of the current bin
            x_lo = MAX(2)/binsHigh * (i-1);
            x_hi = MAX(2)/binsHigh * i;
            y_lo = MAX(1)/binsHigh * (j-1);
            y_hi = MAX(1)/binsHigh * j;
            
            texton_patch = m_channels( (SIFT_pos(:,2) > x_lo) & (SIFT_pos(:,2) <= x_hi) & ...
                                            (SIFT_pos(:,1) > y_lo) & (SIFT_pos(:,1) <= y_hi));

            % make histogram of features in bin
            pyramid_cell{1}(i,j,:) = hist(texton_patch, 1:dictionarySize)./length(m_channels);
        end
    end

    %% compute histograms at the coarser levels
    num_bins = binsHigh/2;
    for l = 2:pyramidLevels
        pyramid_cell{l} = zeros(num_bins, num_bins, dictionarySize);
        for i=1:num_bins
            for j=1:num_bins
                pyramid_cell{l}(i,j,:) = ...
                pyramid_cell{l-1}(2*i-1,2*j-1,:) + pyramid_cell{l-1}(2*i,2*j-1,:) + ...
                pyramid_cell{l-1}(2*i-1,2*j,:) + pyramid_cell{l-1}(2*i,2*j,:);
            end
        end
        num_bins = num_bins/2;
    end

    %% stack all the histograms with appropriate weights
    pyramid = [];
    for l = 1:pyramidLevels-1
        pyramid = [pyramid pyramid_cell{l}(:)' .* 2^(-l)];
    end
    pyramid = [pyramid pyramid_cell{pyramidLevels}(:)' .* 2^(1-pyramidLevels)];
    
end

