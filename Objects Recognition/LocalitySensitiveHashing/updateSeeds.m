function [ seeds ] = updateSeeds( seeds, cluster_ind, features )

    nSeeds = size(seeds, 1);
    for i = 1:nSeeds
        this_elems = (cluster_ind == i);
        if(sum(this_elems)) > 0
            seeds(i,:) = mean(features(this_elems, :));
        end
    end
    
end

