
%% 
%   Test script for doing K-fold nested (training, validation and test) 
%   cross-validations over the ObjVSNoObj Support Vector Machine classifier
%%%%

addpath('..;../Utils;../../DimensionalityReduction;../SpatialPyramidMatching');
%% Spatial Pyramid Matching
feature_params.M = 200; % dimensionality of the vocabulary used (200)
feature_params.L = 2; % number of levels used in the SPM (2)
% Load Scenes vocabulary
load('../Vocabulary/vocabularyS.mat'); % load vocabulary "VS"
load('../Vocabulary/min_normS.mat');
load('../Vocabulary/max_normS.mat');
% Load Objects vocabulary
load('../Vocabulary/vocabulary.mat'); % load vocabulary "V"
load('../Vocabulary/min_norm.mat');
load('../Vocabulary/max_norm.mat');


%% Params
volume_path = 'D:';

% Load objects file
feat_path = [volume_path '/Video Summarization Objects\Features\Data SenseCam 0BC25B01'];
load([feat_path '/objects.mat']);
features_type = 'cnn';

classes = {'Object', 'No Object'};


path_folders = [volume_path '/Documentos/Vicon Revue Data'];
path_labels = [volume_path '/Documentos/Dropbox/Video Summarization Project/Code/Subshot Segmentation/EventsDivision_SenseCam/Datasets'];
folders = {'0BC25B01-7420-DD20-A1C8-3B2BD6C87CB0', '16F8AB43-5CE7-08B0-FD11-BA1E372425AB', ...
    '2E1048A6ECT', '5FA739A3-AAC4-E84B-F7CB-2179AD879AE3', '6FD1B048-A2F2-4CAB-1EFE-266503F59CD3' ...
    '819DC958-7BFE-DCC8-C792-B54B9641AA75', '8B6E4826-77F5-66BF-FCBA-4054D0E84B0B', ...
    'A06514ED-60B5-BF77-5549-2ED885FD7788', 'B07CCAA9-FEBF-E8F3-B637-B021D652CA48', ...
    'D3B168F2-40C8-7BAB-5DA2-4577404BAC7A'};
format = '.JPG';
prop_res = 4;

numTests = 10; % number of TEST divisions
X_fold = 10; % number of cross VALIDATIONS performed
max_iter = 9999999999;
M = 2; % Number of iterations through the cross validation process
balance = true;
treatMethod = 'norm'; % {'norm' = normalize || 'stand' = standardize}
usePCA = true;
params.minVarPCA = 0.95;
params.standarizePCA = true;

% Fraction of the total samples used on the tests
frac_used = 1/10;

%% Prepare different parameters for classification comparison
% numParams = 10;
% params_grid = zeros(2,numParams);
% params_grid(1,:) = linspace(0.1,3,numParams); % sigmas
% params_grid(2,:) = linspace(0.1,3,numParams); % Cs

numParams = 6;
params_grid = zeros(2,numParams);
params_grid(1,:) = [0.1 0.5 3 10 100 1000]; % sigmas
params_grid(2,:) = [0.1 0.5 3 10 100 1000]; % Cs

% numParams = 2;
% params_grid = zeros(2,numParams);
% params_grid(1,:) = [0.1 100]; % sigmas
% params_grid(2,:) = [0.1 100]; % Cs 

feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram (15)
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation (16)
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches (10)
feature_params.lHOG = 3; % number of levels used for the P-HOG (2 better 'PASCAL_07 GT', 3 original)
feature_params.bHOG = 8; % number of bins used for the P-HOG (8)
feature_params.lenCNN = 4096; % length of the vector of features extracted from the CNN (4096)

nClasses = length(classes); % number of classes


%% Go through each folder getting list of images and labels
disp('# PARSING FOLDERS looking for all images...');
[ list_img, list_event, list_event2 ] = parseFolders( folders, path_folders, format, path_labels );

%% Get all indices of all objects in a matrix
indices = [];
nImages = length(objects);
for i = 1:nImages
    nObjects = length(objects(i).objects);
    for j = 1:nObjects
        indices = [indices; i j];
    end
end


%% Recover images features of easiest objects
disp('# RECOVERING FEATURES for easy instances...');
val = zeros(size(indices,1),1); t=0; histClasses = val; show_easiest = false; tests_path = '';
tic %%%%%%%%%%%%%%%%%%%%%%%
% ORIGINAL
if(strcmp(features_type, 'original'))
    [f, event_feat] = recoverFeatures(objects, indices, val, V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res, [1 0], tests_path);
% CONVOLUTIONAL NEURAL NETWORKS
elseif(strcmp(features_type, 'cnn') || strcmp(features_type, 'cnn_con'))
    [appearance_feat, event_feat] = recoverFeatures(objects, indices, val, V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res, [2 0], tests_path);
    % CNN object candidate + CNN scene
    if(strcmp(features_type, 'cnn_con'))
        [appearance_feat] = concatenateCNN(appearance_feat, sceneFeatures, indices);
    end
% LSH DIM. REDUCED
elseif(strcmp(features_type, 'lshDimReduc')) 
    % Appearance
    appearance_feat = features(pos, :);
    % Event Awareness
    [~, event_feat] = recoverFeatures(objects, indices, val, V, V_min_norm, V_max_norm, histClasses, feature_params, feat_path, show_easiest, t, path_folders, prop_res, [0 0], tests_path);
end
all_features = appearance_feat;


%% Recover classes
all_labels = cell(size(all_features,1),1); count = 1;
all_labels_true = cell(size(all_features,1),1);
for ind = indices'
    lab = objects(ind(1)).objects(ind(2)).trueLabel;
    all_labels_true{count} = lab;
    if(~strcmp(lab, 'No Object'))
        lab = 'Object';
    end
    all_labels{count} = lab;
    count = count+1;
end

%% Randomize samples
len = size(all_features,1);
rand = randsample(1:len, len);

% Use only a fraction of all the samples
len = round(len*frac_used);

divs_ = 0:ceil(len/numTests):len;
if(divs_(end) ~= len)
    divs_ = [divs_ len];
end
divs = {};
for i = 1:numTests
    divs{i} = rand((divs_(i)+1):divs_(i+1));
end


%% Open file to write the result
fid = fopen('testResult.txt', 'w');
writeToFile(fid, 'Test Results using: ', true);
writeToFile(fid, ' ', true);
writeToFile(fid, [num2str(X_fold) '-fold BALANCED validations.'], true);
writeToFile(fid, ' ', true);
writeToFile(fid, 'Sigma values: ', true);
writeToFile(fid, params_grid(1,:), true);
writeToFile(fid, 'C values: ', true);
writeToFile(fid, params_grid(2,:), true);
writeToFile(fid, ['With ' num2str(M) ' iterations per parameter value.'], true);

%%%%%%%%%%%%%%%%%%%%%%%
%
%% We apply M times K-fold cross validation for each parameter and for each test set
%
%%%%%%%%%%%%%%%%%%%%%%%
best_Cs = zeros(1, numTests);
best_Sigmas = zeros(1, numTests);
errorsTest = zeros(1, numTests);
for idTest = 1:numTests
    writeToFile(fid, ' ', true);
    writeToFile(fid, '//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////', true);
    writeToFile(fid, '//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////', true);
    writeToFile(fid, ' ', true);
    writeToFile(fid, ['Starting test ' num2str(idTest) '/' num2str(numTests)], true);
    writeToFile(fid, ' ', true);
    writeToFile(fid, '//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////', true);
    writeToFile(fid, '//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////', true);
    writeToFile(fid, ' ', true);
    
    %% Data retrieval for each training set
    features = [];
    counts = zeros(1, nClasses);
    countsTest = zeros(1, nClasses);
    labels = {};
    labelsTest = {};
    elems = {};
    elemsTest = {};
    for idTrain = 1:numTests
        if(idTrain ~= idTest) % training + validation samples
%             load([path_data '/' folder_data{idTrain} '/labels_result.mat']); % labels_result
%             load([path_data '/' folder_data{idTrain} '/featuresNoColour.mat']); % featuresNoColour
%             features = [features; featuresNoColour];
%             labels = [labels labels_result(:).label];
            features = [features; all_features(divs{idTrain},:)];
            labels = {labels{:} all_labels{divs{idTrain}}};
        else % test samples
%             load([path_data '/' folder_data{idTest} '/labels_result.mat']); % labels_result
%             load([path_data '/' folder_data{idTest} '/featuresNoColour.mat']); % featuresNoColour
%             featuresTest = featuresNoColour;
%             labelsTest = [labels_result(:).label];
            featuresTest = all_features(divs{idTrain},:);
            labelsTest = {all_labels{divs{idTrain}}};
        end
    end

    %% Gets all labels
    for i = 1:nClasses
        counts(i) = counts(i) + sum(ismember(labels,classes{i}));
        elems{i} = find((ismember(labels,classes{i}))==1);
        countsTest(i) = sum(ismember(labelsTest,classes{i}));
        elemsTest{i} = find((ismember(labelsTest,classes{i}))==1);
    end
    
    %% Balances the data
    countsB = zeros(1, length(counts));
    if(balance)
        countsB(:) = min(counts);
    else
        countsB = counts;
    end
    nPerGroup = floor(countsB ./ X_fold);
    
    %% Prepares options for SVM
    options = statset('MaxIter', max_iter);
    tic
    results = {};
    for i = 1:nClasses
        results{i} = zeros(counts(i), nClasses*nClasses);
    end

    %% Gets the data separated into X_fold + 1 groups
    X_fold_groups = {};
    for i = 1:nClasses
        rand_indices = randsample(elems{i}, counts(i));
        X_fold_groups{i} = {};
        for j = 1:X_fold
            ini = (j-1)*nPerGroup(i) +1;
            fin = j*nPerGroup(i);
            X_fold_groups{i}{j} = features(rand_indices(ini:fin), :);
        end
        X_fold_groups{i}{X_fold+1} = features(rand_indices((X_fold*nPerGroup(i)+1):end), :);
    end
    
    %% Selects parameters pairs C & Sigma
    all_errors = zeros(numParams,numParams,M);
    all_errors_weighted = zeros(numParams,numParams,M, nClasses);
    countC = 1;
    for C = params_grid(2,:)
        countSigma = 1;
        for sigma = params_grid(1,:)
            writeToFile(fid, ' ', true);
            writeToFile(fid, '------------------------------------------------------------------------------------------------', true);
            writeToFile(fid, ' ', true);
            writeToFile(fid, ['C = ' num2str(C) ', sigma = ' num2str(sigma)], true);
            writeToFile(fid, ['C ' num2str(countC) '/' num2str(numParams) '  ||  Sigma ' num2str(countSigma) '/' num2str(numParams)], true);
            writeToFile(fid, ' ', true);
            writeToFile(fid, '------------------------------------------------------------------------------------------------', true);
            writeToFile(fid, ' ', true);
            for iter = 1:M

                writeToFile(fid, ['Starting validation iteration ' num2str(iter) '/' num2str(M) '...'], true);
                disp(' ');

                %% X-Fold Cross-Validation using ONE vs ALL SVM classifiers
                clear results;
                for j = 1:X_fold

                    writeToFile(fid, ['Starting ' num2str(j) ' out of ' num2str(X_fold) ' fold cross-validations.'], false);

                    xTrain = {}; xTest = {};
                    for i = 1:nClasses % for each class
                        xTrain{i} = []; xTest{i} = [];
                        xTrain{i} = cat(1, X_fold_groups{i}{cat(2, 1:j-1, j+1:X_fold)});
                        xTest{i} = [X_fold_groups{i}{j}];
                        if(j==X_fold)
                            xTest{i} = [xTest{i}; X_fold_groups{i}{X_fold+1}];
                        end
                    end


                    for i = 1:nClasses % for each classifier

                        % Balances the elements
                        if(balance)
                            indices = randsample(1:(size(xTrain{i},1) * (nClasses-1)), size(xTrain{i},1));
                            e = cat(1,xTrain{cat(2,1:i-1,i+1:nClasses)});
                            e = [xTrain{i}; e(indices, :)];
                            c = [ones(size(xTrain{i},1),1);ones(size(xTrain{i},1),1)*-1];
                        else
                            e = cat(1,xTrain{cat(2,1:i-1,i+1:nClasses)});
                            e = [xTrain{i}; e(:, :)];
                            c = [ones(size(xTrain{i},1),1);ones(size(cat(1,xTrain{cat(2,1:i-1,i+1:nClasses)}),1),1)*-1];
                        end

                        if(strcmp(treatMethod, 'norm'))
                            % Normalizes the data
                            [ e, minVals, maxVals ] = normalize( e );
                        elseif(strcmp(treatMethod, 'stand'))
                            [ e, meanD, stdDev ] = standarize( e );
                        end

                        if(usePCA)
                            [e mean stdDev] = applyPCA(e, params);
                        end
                        
                        % Builds the classifier
                        writeToFile(fid, ['    Building classifier ' num2str(i) '/' num2str(nClasses)], false);
                        classifier =  svmtrain(e, c, 'kernel_function', 'rbf', 'rbf_sigma', sigma, 'boxconstraint', C, 'options', options);
            %             classifier =  svmtrain(e, c, 'kernel_function', 'polynomial', 'polyorder', 3, 'options', options);
            %             classifier =  svmtrain(e, c, 'kernel_function', 'mlp', 'options', options);

                        for k = 1:nClasses % for each class

                            if(strcmp(treatMethod, 'norm'))
                                % Normalizes the data
                                [ this_xTest, ~, ~ ] = normalize( xTest{k}, minVals, maxVals );
                            elseif(strcmp(treatMethod, 'stand'))
                                [ this_xTest, ~, ~ ] = standarize( xTest{k}, meanD, stdDev );
                            end

                            if(usePCA)
                                par = params; par.minVarPCA = size(e,2); par.mean = mean; par.stdDev = stdDev;
                                this_xTest = applyPCA(this_xTest, par);
                            end
                            
                            res = svmclassify(classifier, this_xTest);
                            nSamples = size(this_xTest,1);
                            for l = 1:nSamples
                                if( res(l) == 1)
                                    results{k}((j-1)*nPerGroup(i) + l, nClasses*(i-1) + i) = i;
                                else
                                    results{k}((j-1)*nPerGroup(i) + l, nClasses*(i-1) + cat(2,1:i-1,i+1:nClasses)) = cat(2,1:i-1,i+1:nClasses);
                                end
                            end

                        end 

                    end

                end

                writeToFile(fid, ' ', true);

                %% Error check
                resCounts = zeros(nClasses, nClasses); % true_value x assigned_value
                for i = 1:nClasses
                    for j = 1:counts(i)
                        maxClass = 0;
                        maxValue = -1;
                        for k = 1:nClasses
                            this_ocurrences = sum(results{i}(j,:)==k);
                            if(this_ocurrences > maxValue)
                                maxValue = this_ocurrences;
                                maxClass = k;
                            end
                        end
                        resCounts(i, maxClass) = resCounts(i, maxClass)+1;
                    end


                    writeToFile(fid, ['Error class ' num2str(i) ': ' num2str((counts(i)-resCounts(i,i)) / counts(i))], true);
                end

                writeToFile(fid, ' ', true);
                writeToFile(fid, 'Confusion matrix:', true);

                topLine = '    ';
                bottom = {};
                totCounts = sum(resCounts,2);
                % Rows true classes, columns predicted classes
                for i = 1:nClasses
                    topLine = [topLine num2str(i) '    '];
            %         bottom{i} = [num2str(i) '  ' num2str(resCounts(i,:)]; % total value
                    bottom{i} = [num2str(i) '  ' num2str(resCounts(i,:)./totCounts(i))]; % percentage
                end
                writeToFile(fid, topLine, true);
                for i = 1:nClasses
                    writeToFile(fid, bottom{i}, true);
                    
                    all_errors_weighted(countSigma, countC, iter, i) = (1/nClasses) * ((counts(i)-resCounts(i,i)) / counts(i));
                end

                tot_error = 1 - (sum(diag(resCounts)) / sum(sum(resCounts)));
                writeToFile(fid, ' ', true);
                writeToFile(fid, ['>>> Total error: ' num2str(tot_error)], true);
                writeToFile(fid, ' ', true);

                all_errors(countSigma, countC, iter) = tot_error;
            end % end ith iter from M
            countSigma = countSigma+1;
        end % end sigma
        countC = countC+1;
    end % end C

    toc

    %% Display errors
    writeToFile(fid, '##################################################################', true);
    writeToFile(fid, ' ', true);
    % disp('All errors: ');
    % disp(all_errors);
    writeToFile(fid, 'Sigma values: ', true);
    writeToFile(fid, params_grid(1,:), true);
    writeToFile(fid, 'C values: ', true);
    writeToFile(fid, params_grid(2,:), true);
    writeToFile(fid, 'Rows -> Sigma, Columns -> C', true);
    writeToFile(fid, 'Mean error: ', true);
    writeToFile(fid, mean(all_errors,3), true);
    writeToFile(fid, ' ', true);
    writeToFile(fid, 'Std deviation: +-', true);
    writeToFile(fid, std(all_errors,0,3), true);
    writeToFile(fid, ' ', true);
    for i = 1:nClasses
        writeToFile(fid, ['Weighted errors (' num2str(1/nClasses) ' max) for class ' classes(i)] , true);
        writeToFile(fid, mean(all_errors_weighted(:,:,:,i),3), true);
    end
    writeToFile(fid, ' ', true);
    writeToFile(fid, 'Weighted errors mean sum: ', true);
    writeToFile(fid, mean(sum(all_errors_weighted, 4),3), true);
    writeToFile(fid, ' ', true);

    %% Find parameters of min error
    all_errors = sum(all_errors_weighted, 4);
    val = min(min(mean(all_errors,3)));
    [row, col] = find(mean(all_errors,3) == val);
    best_Sigmas(idTest) = params_grid(1, row(1));
    best_Cs(idTest) = params_grid(2, col(1));
    
    writeToFile(fid, ['Best Sigma: ' num2str(best_Sigmas(idTest))], true);
    writeToFile(fid, ['Best C: ' num2str(best_Cs(idTest))], true);
    writeToFile(fid, ' ', true);
    
    %% Apply classification on all TRAINING! (balanced)
    xTrain = {}; xTest = {};
    clear results;
    for i = 1:nClasses
        xTrain{i} = features(randsample(elems{i}, countsB(i)), :);
        xTest{i} = featuresTest(elemsTest{i}, :);
    end
    writeToFile(fid, ' ', true);
    for i = 1:nClasses % for each classifier
        % Balances the elements
        if(balance)
            indices = randsample(1:(size(xTrain{i},1) * (nClasses-1)), size(xTrain{i},1));
            e = cat(1,xTrain{cat(2,1:i-1,i+1:nClasses)});
            e = [xTrain{i}; e(indices, :)];
            c = [ones(size(xTrain{i},1),1);ones(size(xTrain{i},1),1)*-1];
        else
            e = cat(1,xTrain{cat(2,1:i-1,i+1:nClasses)});
            e = [xTrain{i}; e(:, :)];
            c = [ones(size(xTrain{i},1),1);ones(size(cat(1,xTrain{cat(2,1:i-1,i+1:nClasses)}),1),1)*-1];
        end

        if(strcmp(treatMethod, 'norm'))
            % Normalizes the data
            [ e, minVals, maxVals ] = normalize( e );
        elseif(strcmp(treatMethod, 'stand'))
            [ e, meanD, stdDev ] = standarize( e );
        end
        
        if(usePCA)
            [e mean stdDev] = applyPCA(e, params);
        end

        % Builds the classifier
        writeToFile(fid, ['Building classifier ' num2str(i) '/' num2str(nClasses)], false);
        classifier =  svmtrain(e, c, 'kernel_function', 'rbf', 'rbf_sigma', best_Sigmas(idTest), 'boxconstraint', best_Cs(idTest), 'options', options);
%             classifier =  svmtrain(e, c, 'kernel_function', 'polynomial', 'polyorder', 3, 'options', options);
%             classifier =  svmtrain(e, c, 'kernel_function', 'mlp', 'options', options);

        for k = 1:nClasses % for each class

            if(strcmp(treatMethod, 'norm'))
                % Normalizes the data
                [ this_xTest, ~, ~ ] = normalize( xTest{k}, minVals, maxVals );
            elseif(strcmp(treatMethod, 'stand'))
                [ this_xTest, ~, ~ ] = standarize( xTest{k}, meanD, stdDev );
            end
            
            if(usePCA)
                par = params; par.minVarPCA = size(e,2); par.mean = mean; par.stdDev = stdDev;
            	this_xTest = applyPCA(this_xTest, par);
            end

            res = svmclassify(classifier, this_xTest);
            nSamples = size(this_xTest,1);
            for l = 1:nSamples
                if( res(l) == 1)
                    results{k}(l, nClasses*(i-1) + i) = i;
                else
                    results{k}(l, nClasses*(i-1) + cat(2,1:i-1,i+1:nClasses)) = cat(2,1:i-1,i+1:nClasses);
                end
            end

        end 

    end
    
    %% Error check on TEST!
    resCounts = zeros(nClasses, nClasses); % true_value x assigned_value
    for i = 1:nClasses
        for j = 1:size(xTest{i},1)
            maxClass = 0;
            maxValue = -1;
            for k = 1:nClasses
                this_ocurrences = sum(results{i}(j,:)==k);
                if(this_ocurrences > maxValue)
                    maxValue = this_ocurrences;
                    maxClass = k;
                end
            end
            resCounts(i, maxClass) = resCounts(i, maxClass)+1;
        end


        writeToFile(fid, [' >>>>>>>>>> Error class ' num2str(i) ': ' num2str((size(xTest{i},1)-resCounts(i,i)) / size(xTest{i},1))], true);
    end

    writeToFile(fid, ' ', true);
    writeToFile(fid, 'Confusion matrix:', true);

    topLine = '    ';
    bottom = {};
    totCounts = sum(resCounts,2);
    % Rows true classes, columns predicted classes
    for i = 1:nClasses
        topLine = [topLine num2str(i) '    '];
%         bottom{i} = [num2str(i) '  ' num2str(resCounts(i,:)]; % total value
        bottom{i} = [num2str(i) '  ' num2str(resCounts(i,:)./totCounts(i))]; % percentage
    end
    writeToFile(fid, topLine, true);
    for i = 1:nClasses
        writeToFile(fid, bottom{i}, true);
    end

    tot_error = 1 - (sum(diag(resCounts)) / sum(sum(resCounts)));
    writeToFile(fid, ' ', true);
    writeToFile(fid, ['>>>>>>>>>>>>>>>>>> Total error: ' num2str(tot_error)], true);
    writeToFile(fid, ' ', true);
    writeToFile(fid, '##################################################################', true);
    
    errorsTest(idTest) = tot_error;
    
end % end testing on best parameters


%% Print final results for all the TEST evaluations
writeToFile(fid, ' ', true); writeToFile(fid, ' ', true);
writeToFile(fid, '########################################################################################', true);
writeToFile(fid, '########################################################################################', true);
writeToFile(fid, ' ', true);
writeToFile(fid, '>>>>> Sigma values chosen for each test: ', true);
writeToFile(fid, best_Sigmas, true);
writeToFile(fid, '>>>>> C values chosen for each test: ', true);
writeToFile(fid, best_Cs, true);
writeToFile(fid, '>>>>>    Rows -> Sigma, Columns -> C    <<<<<', true);
writeToFile(fid, '>>>>> Error for each test: ', true);
writeToFile(fid, errorsTest, true);
writeToFile(fid, '>>>>> Test folders: ', true);
writeToFile(fid, ' ', true);
writeToFile(fid, '########################################################################################', true);
writeToFile(fid, '########################################################################################', true);


% Close file
fclose(fid);



