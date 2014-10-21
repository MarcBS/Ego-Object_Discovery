function [ result ] = evaluateClustering( objects, indices, clusters, cluster_params )
%EVALUATECLUSTERING Evaluates the clustering result.

    metric = cluster_params.evaluationMethod;
    consider_NoObject = cluster_params.consider_NoObject;
    doPlot = cluster_params.evaluationPlot;
    nClus = length(clusters);
    
    if(doPlot)
        disp('>>> Clustering evaluation results:');
    end
    
    %% Evaluate on each cluster
    result = {};
    for i = 1:nClus
        clus = clusters{i};
        labels = {};
        %% For each element in the cluster
        count_el = 1;
        for el = clus
            ind = indices(el, :);
            k = ind(1); j = ind(2);
            obj = objects(k).objects(j);
            if(~strcmp(obj.trueLabel,'No Object') || consider_NoObject)
                labels{count_el} = obj.trueLabel; % insert label in list
                count_el = count_el +1;
            end
        end
        %% Store majorityVoting result
        if(strcmp(metric, 'majorityVoting'))
            % Get majority label
            un_labels = unique(labels);
            n = zeros(length(un_labels), 1);
            for iy = 1:length(un_labels)
              n(iy) = length(find(strcmp(un_labels{iy}, labels)));
            end
            if(~isempty(n)) % if any sample that isn't No Object
                [v, p] = sort(n, 'descend');
                % Store {majorityLabel, allLabels, #majority}
                majorityLabel = un_labels(p(1));
                result{i} = {majorityLabel{1}, labels, v(1)};
                if(doPlot)
                    disp(['> Cluster ' num2str(i) ': ' num2str(length(labels)) ' samples, majorityLabel "' majorityLabel{1} '"']);
                    disp(['>>   1st: ' num2str(v(1)) ' samples "' majorityLabel{1} '" (' num2str(v(1)/length(labels)*100) ' %).' ]);
                    if(length(v) > 1)
                        this_label = un_labels(p(2));
                        disp(['>>   2nd: ' num2str(v(2)) ' samples "' this_label{1} '" (' num2str(v(2)/length(labels)*100) ' %).' ]);
                        if(length(v) > 2)
                            this_label = un_labels(p(3));
                            disp(['>>   3rd: ' num2str(v(3)) ' samples "' this_label{1} '" (' num2str(v(3)/length(labels)*100) ' %).' ]);
                            if(length(v) > 3)
                                this_label = un_labels(p(4));
                                disp(['>>   4th: ' num2str(v(4)) ' samples "' this_label{1} '" (' num2str(v(4)/length(labels)*100) ' %).' ]);
                                if(length(v) > 4)
                                    this_label = un_labels(p(5));
                                    disp(['>>   5th: ' num2str(v(5)) ' samples "' this_label{1} '" (' num2str(v(5)/length(labels)*100) ' %).' ]);
                                end
                            end
                        end
                    end
                end
            else
                disp(['> Cluster ' num2str(i) ', all "No Object" samples.']);
                result{i} = {'', 0, 0};
            end
        end
    end
    
    %% Evaluate general accuracy
    total = 0; TP = 0;
    for res = result
        total = total + length(res{1}{2});
        TP = TP + res{1}{3};
    end
    result = {result, metric, TP, total};
    if(doPlot)
        disp(['Final accuracy = TP/total = ' num2str(TP) '/' num2str(total) ' = ' num2str(TP/total)]);
        disp(' ');
        disp('Clustering evaluation finished!');
    end
end

