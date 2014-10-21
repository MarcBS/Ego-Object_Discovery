function [ clusters, seeds ] = KMeansClustering( features, cluster_params )
%KMEANSCLUSTERING Applies a clustering based on K-Means.
%%%%

    %% Read parameters
    K = cluster_params.Kclusters;
    
    %% Apply classical K-Means
    [cluster_ind, s] = litekmeans(features', K);
    s = s'; cluster_ind = cluster_ind;
    K = size(s,1); % changes K depending on the final number of clusters obtained
    
    %% Build clusters
    % Sort them by size
    clus = {}; clusters = {};
    clusSizes = zeros(1, K);
    for i = 1:K
        clus{i} = find(cluster_ind == i);
        clusSizes(i) = length(clus{i});
    end
    [~, p] = sort(clusSizes, 'descend');
    
    % Sorting of final output
    seeds = zeros(size(s));
    for i = 1:K
        clusters{i} = clus{p(i)};
        seeds(i,:) = s(p(i),:);
    end
    
end

% figure; hold all;
% % Samples
% scatter(features(find(cluster_ind==1),1),features(find(cluster_ind==1),2), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'r')
% scatter(features(find(cluster_ind~=1),1),features(find(cluster_ind~=1),2), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'g')
% % Seeds
% scatter(seeds(1,1),seeds(1,2), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'b', 'Marker', 'v')
% scatter(seeds(2:end,1),seeds(2:end,2), 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'b', 'Marker', 'v')


