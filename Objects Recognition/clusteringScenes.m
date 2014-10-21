function [ clusters_list, best_cluster, silhouetteCoeffs ] = clusteringScenes( Afeat, Ofeat, cluster_params, feature_params )
%CLUSTERING Applies the chosen clustering technique to the samples.

%     C_types = cluster_params.clustering_type;
    Alevels = cluster_params.AppFeaturesLevels;
    Olevels = cluster_params.ObjectAwareFeaturesLevels;
    nSamples = size(Afeat, 1);
    nLevels = length(Alevels);
    
    % similarities matrix
    simil = zeros(0);

    clusters_list = {1:nSamples};
    %% Go through each level
    for level_count = 1:nLevels
        cType = 'k-means';
        
        %% Go through each subcluster
        tmp_cluster_list = {};
        subcluster_count = 1;
        for c = clusters_list
            c = c{1};
            
            %% Select features we are going to use in each level
            if(strcmp('all', Alevels{level_count}))
                appearance_feat = Afeat(c,:);
            else
                appearance_feat = Afeat(c, Alevels{level_count});
            end
            if(feature_params.useObject)
                if(strcmp('all', Olevels{level_count}))
                    object_feat = Ofeat(c,:);
                else
                    object_feat = Ofeat(c, Olevels{level_count});
                end
            else
                object_feat = [];
            end

            %% K-Means clustering
            disp('# K-Means CLUSTERING...');
            tic %%%%%%%%%%%%%%%%%%%%%%%
            clusters = KMeansClustering([appearance_feat object_feat], cluster_params); 
            toc %%%%%%%%%%%%%%%%%%%%%%%
                
            %% Store result on this subcluster
            for sub_clus = clusters
                tmp_cluster_list{length(tmp_cluster_list)+1} = c(sub_clus{1});
            end
            
            subcluster_count  = subcluster_count + 1;
        end
        
        %% Store result of subclustering into general cluster_list
        clusters_list = tmp_cluster_list;
        
        level_count = level_count + 1;
    end
    
    %% Calculate similarities if not already calculated
    if(isempty(simil))
        % In fact we are calculating distances
        disp('# CALCULATING SIMILARITIES...');
        tic %%%%%%%%%%%%%%%%%%%%%%%
        simil = squareform(pdist(appearance_feat));
        if(~isempty(object_feat))
            simil = simil + squareform(pdist(object_feat));
        end
        toc %%%%%%%%%%%%%%%%%%%%%%%
        cluster_params.max_similarity = 0;
    end
    
    %% Select tightest cluster
    disp('# RANKING CLUSTERS...');
    tic %%%%%%%%%%%%%%%%%%%%%%%
    [clusters_list, silhouetteCoeffs] = bestSilhouetteCoeff(simil, cluster_params.max_similarity, clusters_list, cluster_params.minCluster);
    best_cluster = clusters_list{1};
    toc %%%%%%%%%%%%%%%%%%%%%%%

end

