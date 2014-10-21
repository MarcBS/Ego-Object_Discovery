function [ bClusters, bSeeds, sClusters, sSeeds ] = LSH_K_Means( features, cluster_params )
%LSH_K_MEANS Applies a clustering based on a combination of Locality
%Sensitive Hashing and K-Means.
%   After applying the LSH over the features passed by parameter, it
%   generates k random seeds (based on the average buckets obtained) and
%   applies the K-Means algorithm using the situation of each sample on the
%   different buckets as a metric distance.
%%%%

    %% Read parameters
    nTables = cluster_params.tLSH;
    nBits = cluster_params.bLSH;
    minCluster = cluster_params.minCluster;
    maxBucket = cluster_params.maxBucket;
    stop = cluster_params.fracSamplesCriterion;
    nMaxIter = cluster_params.nMaxIter;
    
    nElems = size(features,1);
    
    %% LSH clustering
    tables = lsh('lsh', nTables, nBits, size(features,2), features', 'B', maxBucket);
    
    %% Seeds initialization
    k = round(length([tables.Index]) / nTables);
    seeds = features(randsample(1:nElems, k),:);
    
    %% While there is some change on the element's cluster index:
    cluster_ind = ones(1, nElems); 
    prev_cluster_ind = zeros(1, nElems);
    iter = 0;
    stop = round(nElems * stop); % stoping criterion
    while(sum(cluster_ind == prev_cluster_ind) < stop && iter < nMaxIter)
        % Show progress
        iter = iter+1;
        disp(['Starting iteration ' num2str(iter) '. Converged ' num2str(sum(cluster_ind == prev_cluster_ind)) '/' num2str(stop)]);
        
        %% Store previous indices
        prev_cluster_ind = cluster_ind;
        
        %% Calculate closest seed for each sample
        seed_ind = getBucketIndicesSeeds(seeds', tables);
        samp_ind = getBucketIndicesSamples(nElems, tables);
        [cluster_ind, sim] = getClosestCluster(seed_ind, samp_ind);
        
        %% Update seeds' position
        seeds = updateSeeds(seeds, cluster_ind, features);

    end
    if(sum(cluster_ind == prev_cluster_ind) >= stop)
        disp(['Convergence achieved by stopping criterion: ' num2str(sum(cluster_ind == prev_cluster_ind)) '/' num2str(stop) ', finished clustering.']);
    else
        disp(['Convergence not achieved, reached ' num2str(nMaxIter) ' iterations.']);
    end
    
    %% Format result for output (separating the too small clusters)
    % Sort them by size
    clusSizes = zeros(1, k);
    for i = 1:k
        clus{i} = find(cluster_ind == i);
        clusSizes(i) = length(clus{i});
    end
    [~, p] = sort(clusSizes, 'descend');
    
    % Separate the bigger than minCluster and the smaller
    pb = p(clusSizes(p) > minCluster);
    ps = p(clusSizes(p) <= minCluster);
    lenPb = length(pb); lenPs = length(ps);
    
    % Insert them in final structure
    bClusters = {}; bSeeds = zeros(length(pb),size(seeds,2));
    sClusters = {}; sSeeds = zeros(length(ps),size(seeds,2));
    for i = 1:lenPb
        bClusters{i} = clus{pb(i)};
        bSeeds(i,:) = seeds(pb(i), :);
    end
    for i = 1:lenPs
        sClusters{i} = clus{ps(i)};
        sSeeds(i,:) = seeds(ps(i), :);
    end
    
end

% figure; hold all;
% % Samples
% scatter(features(find(cluster_ind==1),1),features(find(cluster_ind==1),2), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'r')
% scatter(features(find(cluster_ind~=1),1),features(find(cluster_ind~=1),2), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'g')
% % Seeds
% scatter(seeds(1,1),seeds(1,2), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'b', 'Marker', 'v')
% scatter(seeds(2:end,1),seeds(2:end,2), 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'b', 'Marker', 'v')
