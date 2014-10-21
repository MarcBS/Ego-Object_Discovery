function [ clusters ] = WardClustering( similarities, cluster_params )
%WARDCLUSTERING Applyies Ward Agglomerative clustering.
    
    timesStd = cluster_params.wardStdTimes;

    %% Clustering
    Z = linkage(similarities, 'ward');
    
    
    %% Clusters split
    cut = mean(Z(:,3)) + std(Z(:,3)) * timesStd;
    clustersId = cluster(Z, 'cutoff', cut, 'criterion', 'distance');
    
    
    %% Format output clusters
    clusters = {};
    allIds = unique(clustersId);
    for id = allIds'
        clusters{id} = find(clustersId==id);
    end

    disp(['Formed ' num2str(length(allIds)) ' clusters.']);
    
end

