
%% This script plots the final measures obtained by each method

% Location where all the tests results will be stored
tests_path = '../../../../../../Video Summarization Tests';

%% Parameters 

% Wrong, the scene similarities where not correctly weighted
CNN_Scene = {'Execution_CNN_Scene_1_norm', 'Execution_CNN_Scene_2_norm', ...
    'Execution_CNN_Scene_3_norm'};
CNN_Scene2 = {'Execution_CNN_Scene-v2_1_norm_refill00'};
CNN = {'Execution_CNN_NoScene_1', 'Execution_CNN_NoScene_2', ...
    'Execution_CNN_NoScene_3', 'Execution_CNN_NoScene_4', ...
    'Execution_CNN_NoScene_5','Execution_CNN_NoScene_6', 'Execution_CNN_NoScene_7', ...
    'Execution_CNN_NoScene_8', 'Execution_CNN_NoScene_9', 'Execution_CNN_NoScene_10'};
Original = {'Execution_Original_NoScene_1', 'Execution_Original_NoScene_2', ...
    'Execution_Original_NoScene_3','Execution_Original_NoScene_4', 'Execution_Original_NoScene_5'};
CNN_Refill = {'Execution_CNN_NoScene_1_refill02', 'Execution_CNN_NoScene_2_refill02',...
    'Execution_CNN_NoScene_3_refill03', 'Execution_CNN_NoScene_4_refill04'}; 

% Test variables
% tests = {'CNN_Scene', 'CNN_Scene2', 'Original_NoScene', 'CNN_NoScene', 'CNN_NoScene_Refill'};
tests = {'Original', 'CNN', 'CNN_Refill'};

% Iteration intervals for f-measure plot
iter_intervals = [10 20 40 60 80];

% Max iterations on the fmeasure progress
iterprogress = 1:5:125;

% Font size
font_size = 14;

%% Initialize variables for storing results

% Intermediate F-measures
iterm_fmeasures = {};

% Final iterations
iterations = {};
% Final F-measures
fmeasures = {};
% Final Purity
purities = {};
% Final Accuracy
accuracies = {};
% Final SVM/KNN tests
final_SVM_clus = {};
final_KNN_clus = {};
final_SVM_true = {};
final_KNN_true = {};
for i = 1:length(tests)
    iterm_fmeasures{i} = {};
    iterations{i} = [];
    fmeasures{i} = [];
    purities{i} = [];
    accuracies{i} = [];
    final_SVM_clus{i} = [];
    final_KNN_clus{i} = [];
    final_SVM_true{i} = [];
    final_KNN_true{i} = [];
end

test_names_split = regexp(tests, '_', 'split');
for i = 1:length(test_names_split)
    test_names{i} = [test_names_split{i}{1}];
    for j = 2:length(test_names_split{i})
        test_names{i} = [test_names{i} ' ' test_names_split{i}{j}];
    end
    if(strcmp(test_names{i}, 'Original'))
        test_names{i} = 'Features of [13]';
    end
end

%% Measures on each test type
count_test = 1;
for test = tests
    count_f = 1;
    for f = eval(test{1})
        allIter = dir([tests_path '/ExecutionResults/' f{1} '/resultsObjects*.mat']);
        
        % Fill intermediate fmeasures
        iterm_fmeasures{count_test}{count_f} = [];
        for i = 1:length(allIter)
            load([f{1} '/resultsObjects_' num2str(i) '.mat']); % record
            record = regexp(record, '\\n', 'split');
            part = record{end-2}; part = regexp(part, ': ', 'split');
            iterm_fmeasures{count_test}{count_f} = [iterm_fmeasures{count_test}{count_f} str2num(part{2})];
        end
        
        % Iterations
        iterations{count_test} = [iterations{count_test} length(allIter)];
        
        % Load record
        load([f{1} '/resultsObjects_' num2str(length(allIter)) '.mat']); % record
        record = regexp(record, '\\n', 'split');
        
        % F-measure
        part = record{end-2}; part = regexp(part, ': ', 'split');
        fmeasures{count_test} = [fmeasures{count_test} str2num(part{2})];
        
        % Purity
        part = record{end-5}; part = regexp(part, ': ', 'split');
        purities{count_test} = [purities{count_test} str2num(part{2})];
        
        % Accuracy
        part = record{end-6}; part = regexp(part, ': ', 'split');
        accuracies{count_test} = [accuracies{count_test} str2num(part{2})];
        
        % Fill final SVM/KNN tests
        try
            load([f{1} '/result_SVM_clus.mat']); % result_SVM_clus
            load([f{1} '/result_KNN_clus.mat']); % result_KNN_clus
            load([f{1} '/result_SVM_true.mat']); % result_SVM_true
            load([f{1} '/result_KNN_true.mat']); % result_KNN_true
            final_SVM_clus{count_test} = [final_SVM_clus{count_test} result_SVM_clus.accuracy];
            final_KNN_clus{count_test} = [final_KNN_clus{count_test} result_KNN_clus.accuracy];
            final_SVM_true{count_test} = [final_SVM_true{count_test} result_SVM_true.accuracy];
            final_KNN_true{count_test} = [final_KNN_true{count_test} result_KNN_true.accuracy];
        end
        
        
        count_f = count_f+1;
    end
    count_test = count_test+1;
end
    

%% Plot F-measure/Accuracy/Purity results
outf = []; outp = []; outa = [];
for i = 1:length(tests)
    outf = [outf mean(fmeasures{i})];
    outp = [outp mean(purities{i})];
    outa = [outa mean(accuracies{i})];
end
out = [outf; outp; outa];

figure(1);
bar(out);
colormap(summer);
set(gca,'xticklabel', {'F-Measure', 'Purity', 'Accuracy'}, 'FontSize', font_size)

legend(test_names, 4);


%% Plot F-Measure by iterations
out = [];
for i = 1:length(tests)
    group_test = [];
    for inter = iter_intervals
        this_iterf = [];
        for j = 1:length(iterm_fmeasures{i})
            if(length(iterm_fmeasures{i}{j}) >= inter)
                this_iterf = [this_iterf iterm_fmeasures{i}{j}(inter)];
            else
                this_iterf = [this_iterf NaN];
            end
        end
        group_test = [group_test nanmean(this_iterf)];
    end
    out = [out; group_test];
end

figure(2);
bar(out);
colormap(summer);
set(gca,'xticklabel', test_names)

iter_names = {};
for inter = iter_intervals
    iter_names = {iter_names{:}, [num2str(inter) ' iterations']};
end
legend(iter_names, 2);
ylabel('F-Measure');
set(gca, 'FontSize', font_size);


%% Plot F-Measure progress
figure(3);
for i = 1:length(tests)
    group_test = [];
    for inter = iterprogress
        this_iterf = [];
        for j = 1:length(iterm_fmeasures{i})
            if(length(iterm_fmeasures{i}{j}) >= inter)
                this_iterf = [this_iterf iterm_fmeasures{i}{j}(inter)];
            else
                this_iterf = [this_iterf NaN];
            end
        end
        group_test = [group_test nanmean(this_iterf)];
    end
    plot(iterprogress, group_test, '--', 'Marker', 'v');
    hold all;
end
legend(test_names, 4);
xlabel('Iterations', 'FontSize', font_size);
ylabel('F-Measure', 'FontSize', font_size);
set(gca, 'FontSize', font_size);


%% Plot SVM/KNN final tests
outSVMc = []; outKNNc = []; outSVMt = []; outKNNt = [];
for i = 1:length(tests)
    outSVMc = [outSVMc mean(final_SVM_clus{i})];
    outKNNc = [outKNNc mean(final_KNN_clus{i})];
    outSVMt = [outSVMt mean(final_SVM_true{i})];
    outKNNt = [outKNNt mean(final_KNN_true{i})];
end
out = [outSVMc; outKNNc; outSVMt; outKNNt];

figure(4);
bar(out);
colormap(jet);
set(gca,'xticklabel', {'SVM Clustering', 'KNN Clustering', 'SVM Supervised', 'KNN Supervised'})

legend(test_names, 4);
ylabel('Accuracy', 'FontSize', font_size);
set(gca, 'FontSize', font_size);
