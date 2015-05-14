
%% Parameters
volume_path = '/Volumes/SHARED HD/';
execs_path = [volume_path 'Video_Summarization_Tests/ExecutionResults/'];
path_folders = [volume_path '/Video Summarization Project Data Sets/Narrative_Dataset'];

execution_result = 'Exec_Ferrari_ObjVSNoObj_MSRC_CNN_Refill_6';

plot_dir = '/Volumes/SHARED HD/Video_Summarization_Tests/ObjectsBySubject_Plot';
K_images = 200; % max images to plot per subject
min_obj_per_image = 1;


%% Load results
load([execs_path execution_result '/objects_results.mat']); % objects
load([execs_path execution_result '/classes_results.mat']); % classes

% Define colours
c = colormap(jet);
colours = c(round(linspace(1, size(c,1), length(classes)-2)), :);

%% Split images by subjects
subjects = {};
img_ids = {};
images = objects;
nImages = length(images);
for i = 1:nImages
    subj = regexp(images(i).folder, '/', 'split');
    subj = subj{1}(1:end-1);
    [~, pos] = ismember(subj, subjects);
    if(~pos)
        subjects = {subjects{:}, subj};
        pos = length(subjects);
        img_ids{pos} = [];
    end
    img_ids{pos} = [img_ids{pos} i];
end
nSubjects = length(subjects);

%% Get counts of found objects per image
counts = cell(1, nSubjects);
for i = 1:nSubjects
    nIm_Subject = length(img_ids{i});
    counts{i} = zeros(1, nIm_Subject);
    for k = 1:nIm_Subject
        % Get objects found
        nObjects = length(images(img_ids{i}(k)).objects);
        for j = 1:nObjects
            obj = images(img_ids{i}(k)).objects(j);
            label = obj.label;
            if(~isempty(label) && isempty(obj.initialSelection) && ~strcmp(classes(label+1).name, 'No Object') && ~strcmp(classes(label+1).name, 'Not Analyzed'))
                counts{i}(k) = counts{i}(k) + 1;
            end
        end
    end
end


%% Get K random images per subject
rand_imgs = zeros(nSubjects, K_images);
for i = 1:nSubjects
    this_K = min(sum(counts{i} >= min_obj_per_image), K_images);
    rand_imgs(i,1:this_K) = sort(randsample(img_ids{i}(counts{i} >= min_obj_per_image), this_K));
end

%% Create results dir
if(~exist(plot_dir))
    mkdir(plot_dir);
end

%% Plot found objects for each subject and image
for i = 1:nSubjects
    this_plot_dir = [plot_dir '/' subjects{i}];
    if(~exist(this_plot_dir))
        mkdir(this_plot_dir);
    end
    count = 1;
    for k = rand_imgs(i,:)
        if(k)
            f = figure;
            % Load image
            img = imread([path_folders '/' images(k).folder '/' images(k).imgName]);
            imshow(img);
            % Get objects found
            nObjects = length(images(k).objects);
            for j = 1:nObjects
                obj = images(k).objects(j);
                label = obj.label;
                if(~isempty(label))
                    label_name = classes(label+1).name;
                    if(isempty(obj.initialSelection) && ~strcmp(label_name, 'No Object') && ~strcmp(label_name, 'Not Analyzed'))
                        rectangle('Position',[obj.ULx obj.ULy obj.BRx-obj.ULx obj.BRy-obj.ULy], 'LineWidth',2, 'EdgeColor', colours(label-1, :));
%                         text(obj.ULx, obj.ULy+10, label_name, 'Color', colours(label-1, :), 'FontSize', 20, 'BackgroundColor', 'black');
                        text(obj.ULx, obj.ULy+10, label_name, 'Color', [0.95 0.95 0.95], 'FontSize', 20, 'BackgroundColor', 'black');
                    end
                end
            end
            saveas(f, [this_plot_dir '/img_' num2str(count) '_' images(k).imgName], 'jpg');
            close(gcf);
            count = count+1;
        end
    end
end


disp('Done');