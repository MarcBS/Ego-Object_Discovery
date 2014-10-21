function [ cluster_ind, sim ] = getClosestCluster(seed_ind, samp_ind)

    nSamples = size(samp_ind, 1);
    nSeeds = size(seed_ind, 1);
    
    cluster_ind = zeros(1, nSamples);
    sim = ones(1, nSamples)* -1;
    for i = 1:nSamples
        for j = 1:nSeeds
            this_sim = sum(seed_ind(j,:) == samp_ind(i,:));
            if(this_sim > sim(i))
                sim(i) = this_sim;
                cluster_ind(i) = j;
%             % if they are the same, we change the cluster with a prob of
%             % 0.3
%             elseif(this_sim == sim(i) && rand < 0.3)
%                 sim(i) = this_sim;
%                 cluster_ind(i) = j;
            end
        end
    end

end

