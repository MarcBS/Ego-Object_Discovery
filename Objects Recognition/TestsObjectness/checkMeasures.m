
%% Extracts some measures for evaluating the performance of any objectness 
%   measure applied on a dataset with a defined ground truth.

volume_path = '/Volumes/SHARED HD/';
% volume_path = 'D:/';

% objects_path = 'Video Summarization Objects/Features/Data SenseCam 0BC25B01 SelectiveSearch';
% objects_path = 'Video Summarization Objects/Features/Data PASCAL_12 MCG';
objects_path = 'Video Summarization Objects/Features/Data MSRC Ferrari';
% objects_path = 'Video Summarization Objects/Features/Data PASCAL_07';


%% Load Objects
load([volume_path objects_path '/objects.mat']);


%% Start measures calculation
countTot = 0;
countObjs = 0;
countGT = 0;
countFound = 0;
for i = 1:length(objects)
    this_found = [];
    for j = 1:length(objects(i).objects)
        countTot = countTot+1;
        if(~strcmp('No Object', objects(i).objects(j).trueLabel))
            countObjs = countObjs+1;
            this_found = [this_found; objects(i).objects(j).trueLabelId];
        end
    end
    this_found = unique(this_found);
    countFound = countFound + length(this_found);
    countGT = countGT + length(objects(i).ground_truth);
end

disp(['Total number of images: ' num2str(length(objects))]);
disp(['Total number of object candidates: ' num2str(countTot)]);
disp(['Total number of GT objects: ' num2str(countGT)]);
disp(['Fraction of No Objects found: ' num2str(1-countObjs/countTot)]);
disp(['Detection Rate (DR) of unique objects: ' num2str(countFound/countGT)]);
    
    