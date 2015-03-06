
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


%% Tests Run

for i_test__ = 1:nDatasets__
        
        disp('################################################');
        disp(['##     STARTING CROSS-VALIDATION ' num2str(i_test__) '/' num2str(nDatasets__) '    ##']);
        disp('################################################');
        
        % Load default parameters
        loadParameters;

        % Reload dynamic parameters
        if(strcmp(objectness.type, 'Ferrari'))
            run 'Objectness Ferrari/objectness-release-v2.2/startup'
        elseif(strcmp(objectness.type, 'MCG'))
            thispath = pwd;
            cd(objectness.pathMCG)
            run install
            cd(thispath)
        end

        results_folder = [tests_path '/ExecutionResults/' results_folder '_' num2str(i_test__)];
        mkdir(results_folder);

        % Run test
        main;
        disp(' ');disp(' ');
end