
%% This script plots the final measures obtained by each method

% volume_path = 'D:';
volume_path = '/Volumes/SHARED HD';

% Location where all the tests results will be stored
tests_path = [volume_path '/Video Summarization Tests'];

%% Dataset-specific Parameters 
loadFinalMeasuresELUB;
% loadFinalMeasuresMSRC;
% loadFinalMeasuresPASCAL;

%% Parameters

test_markers = {'s', '*', '+', 'o', 'd', '-', '.', 'x', 'v'};
test_colours = {'r', 'g', 'b', 'm', 'c', 'black', 'y'};

% Iteration intervals for f-measure plot
iter_intervals = [10 20 40 60 80];

% Max iterations on the fmeasure progress
iterprogress = 1:3:100;

% Plot params
font_size = 18;
line_width = 3;

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
% Final precision/recall for each class
precisions = {};
recalls = {};
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
    for j = 1:length(classes_list)
        precisions{i}{j} = [];
        recalls{i}{j} = [];
    end
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
            load([tests_path '/ExecutionResults/' f{1} '/resultsObjects_' num2str(i) '.mat']); % record
            record = regexp(record, '\\n', 'split');
            part = record{end-2}; part = regexp(part, ': ', 'split');
            iterm_fmeasures{count_test}{count_f} = [iterm_fmeasures{count_test}{count_f} str2num(part{2})];
        end
        
        % Iterations
        iterations{count_test} = [iterations{count_test} length(allIter)];
        
        % Load record
        load([tests_path '/ExecutionResults/' f{1} '/resultsObjects_' num2str(length(allIter)) '.mat']); % record
        record = regexp(record, '\\n', 'split');
        
        % Precisions and Recalls
        i = 5; part = regexp(record{i}, ' ', 'split');
        while(strcmp('Precision', part{1}))
            class = regexp(record{i}, '"', 'split'); class = class{2};
            prec = regexp(record{i}, ': ', 'split'); prec = str2num(prec{2});
            rec = regexp(record{i+1}, ': ', 'split'); rec = str2num(rec{2});
            pos = find(ismember(classes_list, class));
            if(~isempty(pos))
                precisions{count_test}{pos} = [precisions{count_test}{pos}; prec];
                recalls{count_test}{pos} = [recalls{count_test}{pos}; rec];
            end
            
            i = i+6;
            part = regexp(record{i}, ' ', 'split');
        end
        
        % F-measures
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
            load([tests_path '/ExecutionResults/' f{1} '/result_SVM_clus.mat']); % result_SVM_clus
            load([tests_path '/ExecutionResults/' f{1} '/result_KNN_clus.mat']); % result_KNN_clus
            load([tests_path '/ExecutionResults/' f{1} '/result_SVM_true.mat']); % result_SVM_true
            load([tests_path '/ExecutionResults/' f{1} '/result_KNN_true.mat']); % result_KNN_true
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
colormap(jet);
set(gca,'xticklabel', {'F-Measure', 'Purity', 'Accuracy'}, 'FontSize', font_size)

legend(tests_legend_names, 4);

%% Plot F-measure results only
figure(2); hold on;
outf = [];
for i = 1:length(tests)
    outf = [outf mean(fmeasures{i})];
end
outf = [outf; zeros(1, length(outf))];
bar(outf);    

colormap(jet);
set(gca, 'xticklabel', '');
ylabel('F-Measure', 'FontSize', font_size);
xlim([0.6, 1.4]);
set(gca, 'FontSize', font_size);

legend(tests_legend_names, 4);

disp('F-Measures:');
disp(tests_legend_names);
disp(outf(1,:));

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

figure(3);
bar(out);
colormap(jet);
set(gca,'xticklabel', tests_legend_names)

iter_names = {};
for inter = iter_intervals
    iter_names = {iter_names{:}, [num2str(inter) ' iterations']};
end
legend(iter_names, 2);
ylabel('F-Measure');
set(gca, 'FontSize', font_size);


%% Plot F-Measure progress
figure(4);
c = colormap(jet);
colours = c(round(linspace(1, size(c,1), length(tests_legend_names))), :);
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
    plot(iterprogress, group_test, '--', 'Marker', 'v', 'LineWidth', line_width, 'Color', colours(i,:));
    hold all;
end
legend(tests_legend_names, 4);
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

figure(5);
bar(out);
colormap(jet);
set(gca,'xticklabel', {'SVM Clustering', 'KNN Clustering', 'SVM Supervised', 'KNN Supervised'})

legend(tests_legend_names, 4);
ylabel('Accuracy', 'FontSize', font_size);
set(gca, 'FontSize', font_size);


%% Plot average Precision/Recall for each object class (type 1)
out = zeros(length(classes_list), length(tests)*2);
leg = {};
for j = 1:length(classes_list)
    for i = 1:length(tests)
        out(j,i*2-1) = mean(precisions{i}{j}); % precision
        out(j,i*2) = mean(recalls{i}{j}); % recall
        leg = {leg{:}, ['Precision - ' tests_legend_names{i}]};
        leg = {leg{:}, ['Recall - ' tests_legend_names{i}]};
    end
end

figure(6);
bar(out);
colormap(jet);
set(gca,'xticklabel', classes_list);

legend(leg, 3);
ylabel('Precision/Recall', 'FontSize', font_size);
set(gca, 'FontSize', font_size);


%% Plot average Precision/Recall for each object class (type 2)
c = colormap(jet);
col = c(round(linspace(1,size(c,1)*0.8, length(classes_list))),:);

figure(7); hold all;
for i = 1:length(tests) 
    plot_group = zeros(2, length(classes_list));
    for j = 1:length(classes_list)
        scatter(mean(recalls{i}{j}), mean(precisions{i}{j}), 80, col(j,:), test_markers{i});
        
        plot_group(1,i) = mean(recalls{i}{j});
        plot_group(2,i) = mean(precisions{i}{j});
%         out(j,i*2-1) = mean(precisions{i}{j}); % precision
%         out(j,i*2) = mean(recalls{i}{j}); % recall
%         leg = {leg{:}, ['Precision - ' test_names{i}]};
%         leg = {leg{:}, ['Recall - ' test_names{i}]};
    end
%     plot(plot_group(1,:), plot_group(2,:), '--', 'Color', col(j,:));
    plot(plot_group(1,:), plot_group(2,:), '--', 'Color', col(1,:));
end

legend(classes_list, 4);
ylabel('Precision', 'FontSize', font_size);
xlabel('Recall', 'FontSize', font_size);
set(gca, 'FontSize', font_size);
