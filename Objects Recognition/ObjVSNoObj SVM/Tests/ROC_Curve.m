
%% Parameters

obj_errors_cell = {};
noobj_errors_cell = {};
test_res_file = 'MSRC_longtest'; % automatically retrieves the cell of noobj and obj errors

columns = 'C';
rows = 'Sigma';
columns_vals = [0.1000  0.5000  3.0000 10.0000  100.0000    1000.0000];
rows_vals = [0.1000  0.5000  3.0000 10.0000 100.0000 1000.0000];

text_size = 16;
line_width = 3;

%% Retrieve errors cell-matrix
file = fileread(['testResult_' test_res_file '.txt']);
file = regexp(file, 'Weighted errors', 'split');
nTests = 1;
for i = 2:3:length(file)
    obj_part = file{i}; obj_part = regexp(obj_part, '\n', 'split'); obj_part = {obj_part{6:end-2}};
    noobj_part = file{i+1}; noobj_part = regexp(noobj_part, '\n', 'split'); noobj_part = {noobj_part{6:end-3}};
    
    obj_errors_cell{nTests} = [];
    noobj_errors_cell{nTests} = [];
    nRows = length(obj_part);
    for j = 1:nRows
        obj_this = regexp(obj_part{j}, ' ', 'split');
        noobj_this = regexp(noobj_part{j}, ' ', 'split');
        row_obj = []; row_noobj = [];
        for k = 3:2:length(obj_this)
            row_obj = [row_obj str2num(obj_this{k})];
            row_noobj = [row_noobj str2num(noobj_this{k})];
        end
        obj_errors_cell{nTests} = [obj_errors_cell{nTests}; row_obj];
        noobj_errors_cell{nTests} = [noobj_errors_cell{nTests}; row_noobj];
    end
    
    nTests = nTests+1;
end

%% Compute mean errors
nRows = length(rows_vals);
nCols = length(columns_vals);

obj_errors = zeros(nRows, nCols);
noobj_errors = zeros(nRows, nCols);
nTests = length(obj_errors_cell);

for i = 1:nRows
    for j = 1:nCols
        for k = 1:nTests
            obj_errors(i,j) = obj_errors(i,j) + obj_errors_cell{k}(i,j);
            noobj_errors(i,j) = noobj_errors(i,j) + noobj_errors_cell{k}(i,j);
        end
    end
end
obj_errors = obj_errors./nTests;
noobj_errors = noobj_errors./nTests;

%% Start ROC computation

% Variable for storing the "Sensitivity" = TPR
sensitivity = zeros(nRows, nCols);
% Variable for storing the "Specificity" = TNR
specificity = zeros(nRows, nCols);

%% Start computation of specificity and sensitivity
for i = 1:nRows
    for j = 1:nCols
        FN = obj_errors(i,j);
        TP = 1-FN;
        FP = noobj_errors(i,j);
        TN = 1-FP;
        sensitivity(i,j) = TP/(TP+FN);
        specificity(i,j) = TN/(FP+TN);
    end
end

%% Plot
colormap jet;
c = colormap; close(gcf);
c = c(round(linspace(1,size(c,1),nRows)), :);

f = figure; hold on;
leg = {};
for i = 1:nRows
    plot(1-specificity(i,:), sensitivity(i,:), 'Color', colormap(c(i,:)), 'LineWidth', line_width, 'Marker', '+');
    for j = 1:nCols
        h = text(1-specificity(i,j)-0.01, sensitivity(i,j)+0.01, num2str(columns_vals(j)), 'Color', colormap(c(i,:)));
        set(h, 'FontSize', text_size);
    end
    leg{i} = ['Sigma ' num2str(rows_vals(i))];
end
legend(leg, 4);
xlabel('1 - Specificity', 'FontSize', text_size);
ylabel('Sensitivity', 'FontSize', text_size);
set(gca, 'FontSize', text_size);

saveas(f, ['roc_curve_' test_res_file '.jpg']);

disp('Done');