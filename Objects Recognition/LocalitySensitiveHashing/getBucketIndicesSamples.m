function [ samp_ind ] = getBucketIndicesSamples( nElems, tables )

    nTables = length(tables);
    samp_ind = zeros(nElems, nTables);
    
    for i = 1:nTables
        nBuckets = length(tables(i).Index);
        for b = 1:nBuckets
            for el = tables(i).Index{b}
                samp_ind(el,i) = b;
            end
        end
    end

end

