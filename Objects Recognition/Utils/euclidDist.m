function [ dist ] = euclidDist( X, Y )

    dist = 0;
    for i = 1:length(X)
        dist = dist + (X(i) - Y(i))^2;
    end
    dist = sqrt(dist);

end

