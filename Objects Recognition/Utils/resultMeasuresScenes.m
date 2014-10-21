function record = resultMeasures( labels, names, showConf )

    disp(' ');
    nClasses = length(labels);
    
    record = '';
    
    % The Rows represent the true classes
    % The Columns represent the predicted classes
    confMatrix = zeros(nClasses, nClasses);
    confMatrixPercentage = zeros(nClasses, nClasses);
    accuracies = zeros(1, nClasses);
    for n = 1:nClasses
        
        this_labels = labels{n};
        % confusion matrix calculation
        for m = 1:nClasses
            confMatrix(n,m) = sum(this_labels==m);
            confMatrixPercentage(n,m) = sum(this_labels==m)/length(this_labels);
        end
        
        % accuracy for each class
        denom = sum(sum(confMatrix));
        if(denom == 0)
            acc = 0;
        else
            acc = (confMatrix(n,n) + sum(sum(confMatrix( [1:n-1 n+1:nClasses] , [1:n-1 n+1:nClasses] )))) / denom;
        end
        accuracies(n) = acc;
        out = ['Accuracy class ' num2str(n) ' "' names{n} '" : ' sprintf('%.3f', acc)];
        disp(out);
        record = [record '\n' out];
    end
    
    %% total accuracy
    disp(' ');
    if(nClasses == 0)
        out = ['Total accuracy: ' sprintf('%.3f', 0)];
    else
        out = ['Total accuracy: ' sprintf('%.3f', sum(accuracies)/nClasses)];
    end
    disp(out);
    record = [record '\n \n' out];

    
    %% show confMatrices
    if(showConf(1))
        disp(' ');
        disp('Confusion Matrix with absolute values:'); labels = '  ';
        for n = 1:nClasses
            labels = [labels sprintf('%5d', n) ' '];
        end
        disp(labels);
        for n = 1:nClasses
            line = [num2str(n) ' '];
            for m = 1:nClasses
                line = [line sprintf('%5d', confMatrix(n,m)) ' '];
            end
            disp(line);
        end
    end
    
    if(showConf(2))
        disp(' ');
        disp('Confusion Matrix with percentage:'); labels = '   ';
        for n = 1:nClasses
            labels = [labels sprintf('%5d', n) '  '];
        end
        disp(labels);
        for n = 1:nClasses
            line = [num2str(n) '  '];
            for m = 1:nClasses
    %             line = [line num2str(confMatrixPercentage(n,m)) ' '];
                line = [line sprintf('%.3f', confMatrixPercentage(n,m)) '  '];
            end
            disp(line);
        end
    end
    

end

