function [ record ] = resultMeasures( labels, topCounts, names, showConf )

    disp(' ');
    nClasses = length(labels);
    
    record = '';
    
    % The Rows represent the true classes
    % The Columns represent the predicted classes
    confMatrix = zeros(nClasses, nClasses);
    confMatrixPercentage = zeros(nClasses, nClasses);
    accuracies = zeros(1, nClasses);
    precisions = zeros(1, nClasses);
    recalls = zeros(1, nClasses);
    purities = zeros(1, nClasses-1);
    for n = 1:nClasses
        this_labels = labels{n};
        % confusion matrix calculation
        for m = 1:nClasses
            confMatrix(n,m) = sum(this_labels==m);
            confMatrixPercentage(n,m) = sum(this_labels==m)/length(this_labels);
        end
    end
        
    for n = 1:nClasses
        %% accuracy for each class
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
        
        %% purity for each class
        if(n > 1)
            denom = sum(sum(confMatrix(2:end, :)));
            if(denom == 0)
                pur = 0;
            else
                pur = (confMatrix(n,n) + sum(sum(confMatrix( [2:n-1 n+1:nClasses] , [1:n-1 n+1:nClasses] )))) / denom;
            end
            purities(n-1) = pur;
            out = ['Purity class ' num2str(n) ' "' names{n} '" : ' sprintf('%.3f', pur)];
            disp(out);
            record = [record '\n' out];
        end
        
        %% precision for each class
        denom = confMatrix(n,n) + sum(confMatrix( [1:n-1 n+1:nClasses] , n ));
        if(denom == 0)
            prec = 0;
        else
            prec = confMatrix(n,n)/denom;
        end
        precisions(n) = prec;
        out = ['Precision class ' num2str(n) ' "' names{n} '" : ' sprintf('%.3f', prec)];
        disp(out);
        record = [record '\n' out];
        
        %% recall for each class
        denom = confMatrix(n,n) + sum(confMatrix( n , [1:n-1 n+1:nClasses] ));
        if(denom == 0)
            rec = 0;
        else
            rec = confMatrix(n,n)/denom;
        end
        recalls(n) = rec;
        out = ['Recall class ' num2str(n) ' "' names{n} '" : ' sprintf('%.3f', rec)];
        disp(out);
        record = [record '\n' out];
        
        %% total true count for each class
        out = ['Total true samples from class ' num2str(n) ' "' names{n} '" : ' num2str(topCounts{n})];
        disp(out);
        record = [record '\n' out];
        
        %% instances of current class labeled so far
        out = ['Instances labeled so far from class ' num2str(n) ' "' names{n} '" : ' num2str(sum(confMatrix(n,:)))];
        disp(out);
        record = [record '\n' out];
        
        disp(' ');
    end
    
    %% total accuracy
    disp(' ');
    if(nClasses == 0)
        out = ['Average accuracy: ' sprintf('%.3f', 0)];
    else
        out = ['Average accuracy: ' sprintf('%.3f', sum(accuracies)/nClasses)];
    end
    disp(out);
    record = [record '\n \n' out];
    
    %% Purity (without "No Object")
    if(nClasses-1 == 0)
        out = 'Purity: 0.00';
    else
        purity = sum(purities) / (nClasses-1); % mean accuracy without "No Objects"
        out = ['Purity: ' sprintf('%.3f', purity)];
    end
    disp(out);
    record = [record '\n' out];
    
    %% total precision (without No Object)
    % With No Object
%     if(nClasses == 0)
%         prec = 0;
%     else
%         prec = sum(precisions)/nClasses;
%     end
    % Without No Object
    if(nClasses < 2)
        prec = 0;
    else
        prec = sum(precisions(2:end))/(nClasses-1);
    end
    out = ['Average precision: ' sprintf('%.3f', prec)];
    disp(out);
    record = [record '\n' out];
    
    %% total recall (without 'No Object')
    % With No Object
%     if(nClasses == 0)
%         rec = 0;
%     else
%         rec = sum(recalls)/nClasses;
%     end
    % Without No Object
    if(nClasses < 2)
        rec = 0;
    else
        rec = sum(recalls(2:end))/(nClasses-1);
    end
    out = ['Average recall: ' sprintf('%.3f', rec)];
    disp(out);
    record = [record '\n' out];
    
    %% F-measure
    if((prec+rec) == 0)
        fmeasure = 0;
    else
        fmeasure = 2*prec*rec / (prec + rec);
    end
    out = ['F-measure: ' sprintf('%.3f', fmeasure)];
    disp(out);
    record = [record '\n' out];
    
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

