function [ clusters ] = completeLinkClustering( S, max_similarity )
%COMPLETELINKCLUSTERING Applies complete-link clustering to the
% similarities in S (sparse matrix) until too high difference.

    % Convert similarities into distances
    S = max_similarity-S;

    clusters = {};
    N = size(S,1);
    %% Put all values in an array for calculating std_deviation and mean
    count = 0;
    for i = 1:N; count = count+(N-i); end
    arrayS = zeros(1,count);
    count = 0;
    for i = 1:(N-1)
        arrayS(count+1:count+(N-i)) = S(i, (i+1):N);
        count = count+(N-i);
    end
    stop = std(arrayS);% / 2; % stopping criterion = std_dev/2
    
    %% Set all samples into individual clusters
    for i = 1:N
        clusters{i} = [i];
    end
    
    %% Find closer clusters until too high difference
    clustering = true; count = 1;
    while(clustering) % while stopping criterion not reached
        [diff, closer] = getMostSimilar(clusters, S);
        if(diff > stop)
            clustering = false;
        else % join clusters
            clusters{closer(1)} = [clusters{closer(1)} clusters{closer(2)}]; % join clusters in 1st
            clusters{closer(2)} = {}; % delete 2nd
        end
        if(mod(count,10) || diff > stop)
            disp(['Clustering step ' num2str(count) '. Stop = ' num2str(stop) ', Diff = ' num2str(diff)]);
        end
        count = count+1;
    end


end

