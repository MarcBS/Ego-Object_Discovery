function [ min_meanDist ] = outAvrgMeanDist( samp_idx, clusters, clus_idx, S )
%OUTAVRGMEANSILHOUETTE Returns min average distance between samp_idx (which
% is in clus_idx) and each of the remaining clusters in "clusters".

    nClusters = length(clusters);
    dists = zeros(1, nClusters);
    
    % For each cluster
    for i = 1:nClusters
        if(i ~= clus_idx) % check over all clusters except the one where this sample belongs to
            c = clusters{i};
            % For each element in this cluster
            for el = c
                % Get distance from sample to any other element
                try
                dists(i) = dists(i) + S(min(samp_idx,el), max(samp_idx,el));
                catch
                    disp('here');
                end
            end
            dists(i) = dists(i) / length(c); % get mean distance to this cluster
        end
    end
    
    min_meanDist = min(dists(setdiff(1:nClusters, clus_idx))); % absolute min distance to any of the clusters

end

