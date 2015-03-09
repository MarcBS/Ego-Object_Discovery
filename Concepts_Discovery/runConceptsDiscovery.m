
%% This script runs the Ego-Object Discovery algorithm using abstract 
%   concrepts instead of real GT labels.
%
% INSTRUCTIONS:
%   - In order to make it work, the first line from the 
%       main.m file: "loadParameters;" must be commented!
%   - Wherever a parameters is NaN then the default configuration 
%       will be used.
%   - In order to know the use and format of each parameter check the
%       file "loadParameters.m".
%%%

%% Define set of changing parameters

nDatasets__ = 10; % number of datasets used (for cross-validation)
% Number of different abstract concrepts resulting from the clustering and 
% that will be introduced to the Bag of Refill.
nConcepts__ = 200;
% Number of samples used in the concrept grouping chosen randomly from all
% of them.
nSamplesUsed__ = 20000;
results_folder__ = 'Exec_ConceptDiscovery';
folders__ = {'Narrative/imageSets/Estefania1_resized', 'Narrative/imageSets/Estefania2_resized', ...
        'Narrative/imageSets/Petia1_resized', 'Narrative/imageSets/Petia2_resized', ...
        'Narrative/imageSets/Mariella_resized', 'SenseCam/imageSets/Day1', 'SenseCam/imageSets/Day2', ...
        'SenseCam/imageSets/Day3', 'SenseCam/imageSets/Day4', 'SenseCam/imageSets/Day6'};

%% Tests Run
cd ..
for i_test__ = 1:nDatasets__
    
        disp('################################################');
        disp(['##     STARTING CROSS-VALIDATION ' num2str(i_test__) '/' num2str(nDatasets__) '         ##']);
        disp('################################################');
        
        % Load default parameters
        loadParameters_ConceptDiscovery;

        % Reload dynamic parameters
        if(strcmp(objectness.type, 'Ferrari'))
            run 'Objectness Ferrari/objectness-release-v2.2/startup'
        elseif(strcmp(objectness.type, 'MCG'))
            thispath = pwd;
            cd(objectness.pathMCG)
            run install
            cd(thispath)
        end

        results_folder = [tests_path '/ExecutionResults/' results_folder__ '_' num2str(i_test__)];
        mkdir(results_folder);
        
        % Load objects file
        load([feat_path '/objects.mat']);
        [objects, classes, ind_train, ind_test] = generateBagOfRefill(objects, folders__, i_test__, nConcepts__, nSamplesUsed__, classes, feature_params, feat_path, path_folders, prop_res);

        % Save current training/test split
        save([results_folder '/ind_train.mat'], 'ind_train');
        save([results_folder '/ind_test.mat'], 'ind_test');
        
        % Run test
        main;
        disp(' ');disp(' ');
end

exit;