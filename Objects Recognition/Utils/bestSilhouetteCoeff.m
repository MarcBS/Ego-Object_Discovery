function [ best, silCoeff ] = bestSilhouetteCoeff( S, max_similarity, clusters, objects, indices, M )
%BESTSILHOUETTECOEFF Returns cluster with highest silhouette coefficient.
%   Returns the cluster with higher silhouette coefficient. In the calculus
%   does not take into account the clusters with less than M samples.
%
%   Reference: Tan, Steinbach, and Kumar. Introduction to Data Mining. 2005.
%
%%%%%%%%

    silCoeff = [];
    best = [];

    % Convert similarities into distances only if max != 0
    if(max_similarity ~= 0) 
        S = max_similarity-S;
    end

    Nclus = length(clusters);
    Nsamp = size(S, 1);
    
    %% Check if any cluster selected
    if(Nclus == 0)
        error('No cluster selected!');
    elseif(Nclus == 1)
        best = {clusters{1}};
    else
        %% Look for cluster with highest silhouette coefficient
        silCoeffSamp = zeros(1,Nsamp);
        silCoeffClus = zeros(1,Nclus);
        for i = 1:Nclus % for each cluster among selected
            len = length(clusters{i});
            for j = 1:len % for each point in the cluster
                % Checks for each sample if it is labeled (1) or not (0)
                if(~isempty(indices))
                    isLabeled = objects(indices(clusters{i}(j), 1)).objects(indices(clusters{i}(j), 2)).label > 0;
                else
                    isLabeled = 0;
                end
                if(~isLabeled)
                    a = inAvrgMeanDist(clusters{i}(j), clusters{i}, S);
                    b = outAvrgMeanDist(clusters{i}(j), clusters, i, S);
                    if(b < a)
                        s = 1 - a/b;
                    else
                        s = b/a - 1;
                    end
                    silCoeffSamp(clusters{i}(j)) = s;
                else
                    silCoeffSamp(clusters{i}(j)) = NaN; % labeled -> not take into account
                end
            end
            % Not takes into account the labeled samples when calculating the 
            % silhouette coefficient (see doRefill.m)
            silCoeffClus(i) = nanmean(silCoeffSamp(clusters{i}));
            if(isnan(silCoeffClus(i)))
                silCoeffClus(i) = -Inf;
            end
        end
        % Sort them by their silCoeff
        [silCoeff, p] = sort(silCoeffClus, 'descend');
        best = {clusters{p}};
    end

end

