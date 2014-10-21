function [ result ] = testSVM( X, Y, model )
%TESTSVM Tests the data provided on the given model.

    nClassifiers = length(model);
    classes_pairs = zeros(nClassifiers,2);
    for i = 1:nClassifiers
        classes_pairs(i,:) = model(i).classes';
    end
    
    resMat = zeros(size(X,1), nClassifiers);
    %% Apply test on each paired classifier
    count = 1;
    for p = classes_pairs'
        predict_label = svmpredict(Y, X, model(count).classifier, '-q');
        resMat(:,count) = predict_label;
        count = count+1;
    end
    
    %% Get majority voting result
    predict_label = mode(resMat, 2);

    result.accuracy = sum(predict_label==Y)/length(Y);
    disp(['Achieved ' sprintf('%.3f', result.accuracy*100) '% of accuracy.']);
end

