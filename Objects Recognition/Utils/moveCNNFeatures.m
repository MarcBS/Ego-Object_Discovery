
path_result = 'D:\Video Summarization Objects\Features\Data SenseCam 0BC25B01';
path_source = 'D:\Video Summarization Objects\Features\Data SenseCam 0BC25B01\CNNFeatures';

%% List folders
folders = dir([path_result '/img*']);
lenF = length(folders);

%% Iterate over each folder
for i = 1:lenF
    load([path_source '/' folders(i).name '/features.mat']); % features
    lenFeat = size(features,1);
    %% Iterate over each object
    for j = 1:lenFeat
        load([path_result '/' folders(i).name '/obj' num2str(j) '.mat']); % obj_feat
        obj_feat.CNN_feat = features(j, :);
        save([path_result '/' folders(i).name '/obj' num2str(j) '.mat'], 'obj_feat');
    end
    disp(['Features from ' num2str(i) '/' num2str(lenF) ' images moved.']);
end

