function [ diff, closer ] = getMostSimilar( clusters, S )

    N = length(clusters);

    maxPairs = zeros(N*(N-1)/2, 2);
    maxDists = zeros(1, N*(N-1)/2);
    count = 1;
    % Go through each pair of clusters
    for i = 1:N
        for j = (i+1):N
            c1 = clusters{i};
            c2 = clusters{j};
            if(~isempty(c1) && ~isempty(c2))
                maxD = -1; %ind = [0 0];
                % Go through each pair of samples in both clusters
                for k = c1
                    for l = c2
                        % Get wider distance between pairs of clusters
                        dist = S(min(k,l),max(k,l));
                        if(dist > maxD)
                            maxD = dist;
                            %ind = [];
                        end
                    end
                end
                maxPairs(count,:) = [i j]; % store maxDist
                maxDists(count) = maxD;
            else % not valid cluster => some cluster was empty 
                maxPairs(count,:) = [i j]; % store maxDist
                maxDists(count) = Inf;
            end
            count = count+1;
        end
    end
    
    % Get closer distance between max distances
    [diff, p] = min(maxDists);
    closer = maxPairs(p,:);

end

