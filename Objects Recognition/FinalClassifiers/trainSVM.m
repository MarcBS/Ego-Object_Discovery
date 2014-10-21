function [ model ] = trainSVM( X, Y, final_params )
%TRAINSVM Trains a final OneVsOne SVM classifier.

    params = final_params.SVM;
    
    uniqueClasses = unique(Y);
    classes_pairs = combnk(uniqueClasses, 2);
    
    %% Train a classifier for each pair of classes
    count = 1;
    for pair = classes_pairs'
        model(count).classes = pair;
        ind1 = Y==pair(1);
        ind2 = Y==pair(2);
        
        % Balance classes' samples
        if(length(ind1) > length(ind2))
            ind1 = ind1(randsample(1:length(ind1), length(ind2)));
        elseif(length(ind1) < length(ind2))
            ind2 = ind2(randsample(1:length(ind2), length(ind1)));
        end
        
        model(count).classifier = svmtrain([Y(ind1); Y(ind2)], [X(ind1,:); X(ind2,:)], params);
        count = count+1;
    end

end

