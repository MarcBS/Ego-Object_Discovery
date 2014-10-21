function [ best, silCoeff ] = bestSilhouetteCoeff( S, max_similarity, clusters, M )
%BESTSILHOUETTECOEFF Returns cluster with highest silhouette coefficient.
%   Returns the cluster with higher silhouette coefficient. In the calculus
%   does not take into account the clusters with less than M samples.
%
%   Reference: Tan, Steinbach, and Kumar. Introduction to Data Mining. 2005.
%
%%%%%%%%

    % Convert similarities into distances
    S = max_similarity-S;

    C = {};
    Nclus = length(clusters);
    Nsamp = size(S, 1);
    indices = [];
    
    %% Select only clusters with M samples minimum
    count = 0;
    for i = 1:Nclus
        if(length(clusters{i}) >= M)
            C{count+1} = clusters{i};
            indices = [indices; i];
            count = count+1;
        end
    end
    Nclus = length(C);
    
    %% Check if any cluster selected
    if(count == 0)
        error('No cluster selected!');
    elseif(count == 1)
        best = C{1};
    else
        %% Look for cluster with highest silhouette coefficient
        silCoeffSamp = zeros(1,Nsamp);
        silCoeffClus = zeros(1,Nclus);
        for i = 1:count % for each cluster among selected
            len = length(C{i});
            for j = 1:len % for each point in the cluster
                a = inAvrgMeanDist(C{i}(j), C{i}, S);
                b = outAvrgMeanDist(C{i}(j), C, i, S);
                if(b < a)
                    s = 1 - a/b;
                else
                    s = b/a - 1;
                end
                silCoeffSamp(C{i}(j)) = s;
            end
            silCoeffClus(i) = mean(silCoeffSamp(C{i}));
        end
        % Sort them by their silCoeff
        [silCoeff, p] = sort(silCoeffClus, 'descend');
        best = {clusters{indices(p)}};
    end

end

