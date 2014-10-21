function [ clusters ] = LSHclustering( features, cluster_params )
%LSHCLUSTERING Applies a clustering on the elements defined by "features"
%   using LSH.
%   Uses Locality Sensitive Hashing for applying a clustering to the
%   samples in "features" keeping and returning only the clusters with more
%   than "minCluster" elements, each cluster is composed by their 
%   corresponding index in the features matrix.
%
%   features = NxM matrix with N samples and M features each.
%   clusterParams.minCluster = number of minimum elements that a cluster must have to be
%       returned.
%   clusterParams.tLHS and clusterParams.bLSH = number of tables created and number of bits used in
%       their creation when applying the LSH.
%   clusterParams.nSamplesCriterion = number of minimum samples used on the table selection criterion.
%%%%

    %% Read parameters
    nTables = cluster_params.tLSH;
    nBits = cluster_params.bLSH;
    nSamples = cluster_params.nSamplesCriterion;
    minCluster = cluster_params.minCluster;
    maxBucket = cluster_params.maxBucket;
    choosing_criterion = cluster_params.choosing_criterion;

    %% LSH clustering
    tables = lsh('lsh', nTables, nBits, size(features,2), features', 'B', maxBucket);
    
    if(strcmp(choosing_criterion, 'maxBig'))
        %% Check the number of buckets bigger than nSamples on each table.
        nClusBigger = zeros(1, nTables);
        for i = 1:nTables
            t = tables(i);
            count_b = 0;
            lenBuckets = length(t.Index);
            for b = 1:lenBuckets
                if(length(t.Index{b}) > nSamples)
                    count_b = count_b +1;
                end
            end
            nClusBigger(i) = count_b;
        end

        %% Get the table with more buckets bigger than nSamples
        [~, p] = max(nClusBigger);
        clus = tables(p).Index;
        lenBuckets = length(clus);

    elseif(strcmp(choosing_criterion, 'minAvrg'))
        %% Check the average number of samples in buckets on each table.
        [nClusAvrg]=lshstats(tables);

        %% Get the table with lower average
        [~, p] = min(nClusAvrg);
        clus = tables(p).Index;
        lenBuckets = length(clus);
    end
    
    %% Sort them by size
    clusSizes = zeros(1, lenBuckets);
    for i = 1:lenBuckets
        clusSizes(i) = length(clus{i});
    end
    [~, p] = sort(clusSizes, 'descend');
    
    %% Select only the ones bigger than minCluster
    p = p(clusSizes(p) > minCluster);
    lenP = length(p);
    
    %% Insert them in final structure
    clusters = {};
    for i = 1:lenP
        clusters{i} = clus{p(i)};
    end
    
end

