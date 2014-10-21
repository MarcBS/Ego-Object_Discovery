function [ seed_ind ] = getBucketIndicesSeeds( seeds, tables )
    
    nSamples = size(seeds, 2);
    nTables = length(tables);
    seed_ind = zeros(size(seeds,2), nTables);
    
    for i = 1:nTables
        for j = 1:nSamples
            bucks = findbucket(tables(i).type, seeds(:,j), tables(i).I);
            keys = lshhash(bucks); % find the bucket in i-th table
            match = [tables(i).bhash{keys}]; % possible matching buckets
            if(~isempty(match))
                [~,p] = max(sum(bsxfun(@eq,bucks,tables(i).buckets(match,:)),2));
                seed_ind(j,i) = match(p);
            else
                seed_ind(j,i) = -1;
            end
        end
    end

end

