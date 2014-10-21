function [ clusters_list, best_cluster, silhouetteCoeffs ] = clustering( Afeat, Efeat, Sfeat, cluster_params, feature_params, objects, indices )
%CLUSTERING Applies the chosen clustering technique to the samples.

    C_types = cluster_params.clustering_type;
    Alevels = cluster_params.AppFeaturesLevels;
    Elevels = cluster_params.EventAwareFeaturesLevels;
    Slevels = cluster_params.SceneAwareFeaturesLevels;
%     Clevels = cluster_params.ContextAwareFeaturesLevels;
    nSamples = size(Afeat, 1);
    
    % Only continue if we have more than one sample
    if(nSamples > 1)
        nLevels = length(C_types);

        % similarities matrix
        simil = zeros(0);

        clusters_list = {1:nSamples};
        %% Go through each level
        level_count = 1;
        for cType = C_types
            cType = cType{1};

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
                if(feature_params.useScene)
                    if(strcmp('all', Slevels{level_count}))
                        scene_feat = Sfeat(c,:);
                    else
                        scene_feat = Sfeat(c, Slevels{level_count});
                    end
                else
                    scene_feat = [];
                end
                if(feature_params.useEvent)
                    if(strcmp('all', Elevels{level_count}))
                        event_feat = Efeat(c,:);
                    else
                        event_feat = Efeat(c, Elevels{level_count});
                    end
                else
                    event_feat = [];
                end
                if(feature_params.useContext)
                    if(strcmp('all', Clevels{level_count}))
                        context_feat = Cfeat(c,:);
                    else
                        context_feat = Cfeat(c, Clevels{level_count});
                    end
                else
                    context_feat = [];
                end

                %% Complete-Link clustering
                if(strcmp(cType, 'clink'))
                    %% Calculate similarities between easiest samples
                    disp('# CALCULATING SIMILARITIES...');
                    tic %%%%%%%%%%%%%%%%%%%%%%%
                    simil = chi_squareSimilarities(appearance_feat, event_feat, scene_feat);
                    toc %%%%%%%%%%%%%%%%%%%%%%%

                    %% Complete-link clustering
                    disp('# COMPLETE-LINK CLUSTERING...');
                    tic %%%%%%%%%%%%%%%%%%%%%%%
                    clusters = completeLinkClustering(simil, cluster_params.max_similarity);
                    toc %%%%%%%%%%%%%%%%%%%%%%%

                %% Locality Sensitive Hashing (LSH)
                elseif(strcmp(cType, 'lsh'))
                    disp('# LSH CLUSTERING...');
                    tic %%%%%%%%%%%%%%%%%%%%%%%
                    clusters = LSHclustering([appearance_feat event_feat scene_feat], cluster_params); 
                    toc %%%%%%%%%%%%%%%%%%%%%%%

                %% LSH and K-Means (LSH-K-Means)
                elseif(strcmp(cType, 'lsh-k-means'))
                    disp('# LSH-K-MEANS CLUSTERING...');
                    tic %%%%%%%%%%%%%%%%%%%%%%%
                    [clusters, seeds, ~, ~] = LSH_K_Means([appearance_feat event_feat scene_feat], cluster_params);
                    toc %%%%%%%%%%%%%%%%%%%%%%%

                %% K-Means clustering
                elseif(strcmp(cType, 'k-means'))
                    disp('# K-Means CLUSTERING...');
                    tic %%%%%%%%%%%%%%%%%%%%%%%
                    clusters = KMeansClustering([appearance_feat event_feat scene_feat], cluster_params); 
                    toc %%%%%%%%%%%%%%%%%%%%%%%

                %% Agglomerative Ward clustering
                elseif(strcmp(cType, 'ward'))
                    disp('# CALCULATING SIMILARITIES...');
                    tic %%%%%%%%%%%%%%%%%%%%%%%
                    [simil, cluster_params] = getSimilarities(appearance_feat, event_feat, scene_feat, context_feat, cluster_params, feature_params);
                    toc %%%%%%%%%%%%%%%%%%%%%%%

                    disp('# Ward CLUSTERING...');
                    tic %%%%%%%%%%%%%%%%%%%%%%%
                    clusters = WardClustering(simil, cluster_params); 
                    toc %%%%%%%%%%%%%%%%%%%%%%%
                end

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
            disp('# CALCULATING SIMILARITIES...');
            tic %%%%%%%%%%%%%%%%%%%%%%%
            [simil, cluster_params] = getSimilarities(appearance_feat, event_feat, scene_feat, context_feat, cluster_params);
            toc %%%%%%%%%%%%%%%%%%%%%%%
        end

        %% Select tightest cluster
        disp('# RANKING CLUSTERS...');
        tic %%%%%%%%%%%%%%%%%%%%%%%
        [clusters_list, silhouetteCoeffs] = bestSilhouetteCoeff(simil, cluster_params.max_similarity, clusters_list, objects, indices, cluster_params.minCluster);
        best_cluster = clusters_list{1};
        toc %%%%%%%%%%%%%%%%%%%%%%%

    else
        clusters_list = {1};
        best_cluster = {1};
        silhouetteCoeffs = [1];
    end
end

