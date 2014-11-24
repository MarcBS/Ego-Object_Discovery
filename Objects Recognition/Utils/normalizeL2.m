function [ X, minimum, maximum ] = normalizeL2( X, minimum, maximum )

    for i=1:size(X,1)
        nn = norm(X(i,:));
        if(nn~=0)
            X(i,:) = X(i,:) ./ nn;
        end
    end

end