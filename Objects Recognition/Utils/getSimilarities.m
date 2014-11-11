function [ simil, cluster_params ] = getSimilarities( appearance_feat, event_feat, scene_feat, context_feat, cluster_params, feature_params )

    % In fact we are calculating distances
    simil = squareform(pdist(appearance_feat), cluster_params.similDist);
    % Normalization
    minS = min(min(simil)); maxS = max(max(simil));
    simil = (simil-minS)/(maxS-minS);
    
    if(~isempty(event_feat))
        evnt_sim = squareform(pdist(event_feat), cluster_params.similDist);
        % Normalization
        minS = min(min(evnt_sim)); maxS = max(max(evnt_sim));
        simil = simil + (evnt_sim-minS)/(maxS-minS);
    end
    if(~isempty(scene_feat))
        if(feature_params.scene_version == 1)
            scn_simil = squareform(pdist(scene_feat), cluster_params.similDist);
        elseif(feature_params.scene_version == 2)
            scn_simil = squareform(pdist(scene_feat), cluster_params.similDist);
%             scn_simil_1 = squareform(pdist(scene_feat(:,2:end)));
%             % apply hamming distance on the first attribute (scene class)
%             scn_simil_2 = squareform(pdist(scene_feat(:,1), 'hamming'))*(1/(size(scene_feat,2)-1));
%             scn_simil = scn_simil_1 + scn_simil_2;
        end
        % Normalization
        minS = min(min(scn_simil)); maxS = max(max(scn_simil));
        simil = simil + (scn_simil-minS)/(maxS-minS);
    end
    if(~isempty(context_feat))
        cntx_simil = squareform(pdist(context_feat), cluster_params.similDist);
        % Normalization
        minS = min(min(cntx_simil)); maxS = max(max(cntx_simil));
        simil = simil + (cntx_simil-minS)/(maxS-minS);
    end
    cluster_params.max_similarity = 0;

end

