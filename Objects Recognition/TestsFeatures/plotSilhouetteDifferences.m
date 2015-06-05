

%% Parameters
path_folders = '/Volumes/SHARED HD/Video_Summarization_Tests/Clusters Results/Silhouette_Tests/';

tests = {'Clustering_Objects_ward_Silhouette_Exec_Ferrari_CNN_iter', 'Clustering_Objects_ward_Silhouette_Exec_Ferrari_Grauman_iter'};
tests_names = {'CNN', 'Grauman Features'};
colors = {'b', 'r'};

top = 15;

%% Get all silhouette values
nTests = length(tests);
coeffs = cell(nTests,1);
for i = 1:nTests
    all_super_folders = dir([path_folders tests{i} '*']);
    nSuperFolders = length(all_super_folders);
    coeffs{i} = cell(nSuperFolders,1);
    N = [];
    for j = 1:nSuperFolders
        n = regexp(all_super_folders(j).name, tests{i}, 'split');
        N(j) = str2num(n{2});
        all_sub_folders = dir([path_folders all_super_folders(j).name '/*']);
        all_sub_folders = all_sub_folders(3:end); % remove hidden folders
        nSubFolders = length(all_sub_folders);
        coeffs{i}{j} = zeros(1, nSubFolders);
        for k = 1:nSubFolders 
            this_coeff = regexp(all_sub_folders(k).name, '=', 'split');
            coeffs{i}{j}(k) = str2num(this_coeff{2});
        end
        % Sort values
        coeffs{i}{j} = sort(coeffs{i}{j}, 'descend');
    end
    [~, ord] = sort(N);
    coeffs{i} = {coeffs{i}{ord}};
end


%% Plot coefficients
for i = 1:nTests
    this_all = [];
    for j = 1:nSuperFolders
%         plot(coeffs{i}{j}(1:top), 'Color', colors{i});
        this_all = [this_all; coeffs{i}{j}(1:top)];
        hold on;
    end
    plot(mean(this_all), '-*', 'Color', colors{i}, 'LineWidth', 4);
%     errorbar(mean(this_all), abs(mean(this_all)-std(this_all)), 'rx', 'Color', colors{i});
end
for i = 1:nTests
    this_all = [];
    for j = 1:nSuperFolders
        this_all = [this_all; coeffs{i}{j}(1:top)];
        hold on;
    end
    plot(mean(this_all)-std(this_all), '-*', 'Color', colors{i}, 'LineWidth', 1);
    plot(mean(this_all)+std(this_all), '-*', 'Color', colors{i}, 'LineWidth', 1);
%     errorbar(mean(this_all), abs(mean(this_all)-std(this_all)), 'rx', 'Color', colors{i});
end
ylabel('Mean Silhouette Coefficient', 'FontSize', 20);
xlabel(['Top-' num2str(top) ' Clusters'], 'FontSize', 20);
ylim([0 0.55]);
xlim([0.5 top+.5]);
set(gca, 'XTick', 1:top, 'FontSize', 15);
grid on;
legend(tests_names);

disp('Done');