function [ model ] = trainKNN( X, Y, final_params )
%TRAINKNN Trains a final KNN classifier.

    K = final_params.KNN;
    
    model = ClassificationKNN.fit(X, Y, 'NumNeighbors', K);

end

