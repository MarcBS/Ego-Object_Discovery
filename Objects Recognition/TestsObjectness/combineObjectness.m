
%% Applies a combination of different objectness measure results

% volume_path = '/Volumes/SHARED HD/';
volume_path = 'D:/';

folder1 = 'Video Summarization Objects/Features/Data SenseCam 0BC25B01 BING';
type1 = 'BING';
folder2 = 'Video Summarization Objects/Features/Data SenseCam 0BC25B01';
type2 = 'Ferrari';
folder_new = 'Video Summarization Objects/Features/Data SenseCam 0BC25B01 COMBINED';

min_overlap = 0.55;
W = 50;

% Combination mode: {1: find pairs of windows with high enough OS and apply mean
%                    2: get best windows from each method}
mode = 2;

%% Load Objects
load([volume_path folder1 '/objects.mat']);
objects1 = objects;
load([volume_path folder2 '/objects.mat']);
objects2 = objects;

% Prepare new struct of objects
new_objects = objects1;
allFound = 0;

%% Start looking for combined candidates
nImgs = length(objects1);
for i = 1:nImgs
    new_candidates = zeros(W*W, 5);
    nFound = 0;
    new_objects(i).objects = struct('ULx', [], 'ULy', [], ...
        'BRx', [], 'BRy', [], 'objScore', [], 'eventAwareScore', [], 'features', [], 'label', 0);
    
    if(mode == 1)
        % Check each pair of object candidates
        nObjs1 = length(objects1(i).objects);
        for j = 1:nObjs1
            nObjs2 = length(objects2(i).objects);

            obj1 = objects1(i).objects(j);

            obj1.height = (obj1.BRy - obj1.ULy + 1);
            obj1.width = (obj1.BRx - obj1.ULx + 1);
            obj1.area = obj1.height * obj1.width;

            for k = 1:nObjs2
                %% Starts looking for pairs of candidates with big enough overlap score
                obj2 = objects2(i).objects(k);

                obj2.height = (obj2.BRy - obj2.ULy + 1);
                obj2.width = (obj2.BRx - obj2.ULx + 1);
                obj2.area = obj2.height * obj2.width;

                % Check intersection and overlap score
                count_intersect = rectint([obj1.ULy, obj1.ULx, obj1.height, obj1.width], [obj2.ULy, obj2.ULx, obj2.height, obj2.width]);
                OS = count_intersect / (obj1.area + obj2.area - count_intersect);

                % New candidate found!
                if(OS >= min_overlap)
                    nFound = nFound+1;
                    new_candidates(nFound,:) = meanObject({obj1, obj2}, {type1, type2});
                end
            end
        end
        
    elseif(mode==2)
        count = 1;
        for j = 1:(W/2)
            if(strcmp(type1,'BING'))
                new_candidates(count, 1) = 1+objects1(i).objects(j).objScore;
            elseif(strcmp(type1,'Ferrari'))
                new_candidates(count, 1) = objects1(i).objects(j).objScore;
            end
            new_candidates(count, 2) = objects1(i).objects(j).ULx;
            new_candidates(count, 3) = objects1(i).objects(j).ULy;
            new_candidates(count, 4) = objects1(i).objects(j).BRx;
            new_candidates(count, 5) = objects1(i).objects(j).BRy;
            count = count+1;
        end
        for j = 1:(W/2)
            if(strcmp(type2,'BING'))
                new_candidates(count, 1) = 1+objects2(i).objects(j).objScore;
            elseif(strcmp(type2,'Ferrari'))
                new_candidates(count, 1) = objects2(i).objects(j).objScore;
            end
            new_candidates(count, 2) = objects2(i).objects(j).ULx;
            new_candidates(count, 3) = objects2(i).objects(j).ULy;
            new_candidates(count, 4) = objects2(i).objects(j).BRx;
            new_candidates(count, 5) = objects2(i).objects(j).BRy;
            count = count+1;
        end
    end
    
    %% Sort all found candidates by their objectness score and get the best ones
    [v,p] = sort(new_candidates(:,1), 'descend');
    nChoose = min(W, sum(v>0));
    new_candidates = new_candidates(p(1:nChoose),:);
    
    for j = 1:nChoose
        new_objects(i).objects(j).objScore = new_candidates(j,1);
        new_objects(i).objects(j).ULx = new_candidates(j,2);
        new_objects(i).objects(j).ULy = new_candidates(j,3);
        new_objects(i).objects(j).BRx = new_candidates(j,4);
        new_objects(i).objects(j).BRy = new_candidates(j,5);
    end
    allFound = allFound + nChoose;
    
    %% Show progress
    if(mod(i,50)==0)
        disp(['Processed ' num2str(i) '/' num2str(nImgs) ' images.']);
        disp(['Found ' num2str(allFound) ' candidates so far.']);
    end
end


%% Store result
mkdir([volume_path folder_new]);
objects = new_objects;
save([volume_path folder_new '/objects.mat'], 'objects');
copyfile([volume_path folder1 '/Annotations'], [volume_path folder_new '/Annotations'], 'f');
