function [ meanDist ] = inAvrgMeanDist( samp_idx, cluster, S )
%INAVRGMEANSILHOUETTE Returns mean distance between samp_idx and the rest
% of samples in this cluster.

    dist = 0;
    c = setdiff(cluster, samp_idx);
    % for each element in the cluster
    for el = c
        dist = dist + S(min(samp_idx,el), max(samp_idx,el));
    end
    meanDist = dist/length(c);

end

