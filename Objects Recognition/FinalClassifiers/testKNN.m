function [ result ] = testKNN( X, Y, model )
%TESTKNN Tests the data provided on the given model.

    % Test evaluation
    pred_label = predict(model, X);
    
    % Accuracy evaluation
    result.accuracy = sum(pred_label==Y)/length(Y);
    disp(['Achieved ' sprintf('%.3f', result.accuracy*100) '% of accuracy.']);
end

