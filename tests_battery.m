%% This scripts provides a way of appling a battery of tests for the
% object discovery algorithm.
%
% INSTRUCTIONS:
%   - In order to make it work, the first line from the 
%       main.m file: "loadParameters;" must be commented!
%   - Wherever a parameters is NaN then the default configuration 
%       will be used.
%   - There must always be the same number of nTests__ than values
%       on each parameter list.
%   - In order to know the use and format of each parameter check the
%       file "loadParameters.m".
%%%

%% Define set of changing parameters (MODIFY THIS PART)
nTests__ = 2;

%%% Objectness
easiness_rate__ = {NaN, NaN};
objectness__type__ = {'Ferrari', 'BING'};

%%% Dataset
prop_res__ = {4, 1};
volume_path__ = {NaN, NaN};
results_folder__ = {'Exec_CNN_Refill_Ferrari_ObjVSNoObj_OneClassOut_1', ...
    'Exec_CNN_Refill_Ferrari_ObjVSNoObj_OneClassOut_2'};
folders__ = {{'JPEGImages'}, {'JPEGImages'}};
format__ = {'.jpg', '.jpg'};
% write path without "volume_path"!
path_folders__ = {'/Video Summarization Project Data Sets/PASCAL_12/VOCdevkit/VOC2012/', ...
    '/Video Summarization Project Data Sets/PASCAL_12/VOCdevkit/VOC2012/'};
feat_path__ = {'/Users/Lifelogging/Desktop/Obj_Disc PASCAL/Data SenseCam 0BC25B01 Ferrari', ...
    '/Users/Lifelogging/Desktop/Obj_Disc PASCAL/Data SenseCam 0BC25B01 BING'};

%%% Features
features_type__ = {'cnn', 'original'};
feature_params__initialScenesPercentage__ = {1, 1};
feature_params__initialObjectsPercentage__ = {0.4, 0.4};
feature_params__initialObjectsClassesOut__ = {0.25, 0.25};

%%% Optional MAIN processes
reload_objStruct__ = {false, false};
reload_objectness__ = {false, false};
reload_features__ = {false, false};
reload_features_scenes__ = {false, false};
% retrain_obj_vs_noobj__ = {false, false}; (DEPRECATED)
apply_obj_vs_noobj__ = {false, false};
do_discovery__ = {false, false};
do_final_evaluation__ = {false, false};

%%% Others
feature_params__usePCA__ = {false, false};
refill__ = {0.2, 0.2};
objVSnoobj_params__SVMpath__ = {'PASCAL_12', 'MSRC'};
cluster_params__similDist__ = {'cosine', 'euclidean'};


%%% List of parameters defined in this section
parameters_list__ = {'easiness_rate__', 'objectness__type__', 'prop_res__', ...
    'volume_path__', 'results_folder__', 'folders__', 'format__', 'path_folders__', ...
    'feat_path__', 'features_type__', 'feature_params__initialScenesPercentage__', ...
    'feature_params__initialObjectsPercentage__', 'feature_params__initialObjectsClassesOut__', ...
    'reload_objStruct__', 'reload_objectness__', 'reload_features__', ...
    'reload_features_scenes__', 'apply_obj_vs_noobj__', 'do_discovery__', ...
    'do_final_evaluation__', 'feature_params__usePCA__', 'refill__', ...
    'objVSnoobj_params__SVMpath__', 'cluster_params__similDist__'};


%% Tests Run (DO NOT MODIFY THIS PART)

for i_test__ = 1:nTests__
    disp('################################################');
    disp(['##        STARTING TEST BATTERY ' num2str(i_test__) '/' num2str(nTests__) '           ##']);
    disp('################################################');
    
    % Load default parameters
    loadParameters;

    % Change test-dependent parameters
    for param__ = parameters_list__
        
        % Format battery parameter name
        param_this__ = param__{1};
        
        % Format original parameter name
        param__ = param__{1}(1:end-2);
        param__ = regexp(param__, '__', 'split');
        param_original__ = '';
        for part__ = param__
            param_original__  = [param_original__ part__{1} '.'];
        end
        param_original__ = param_original__(1:end-1);
        
        % Check if battery param is 'NaN'
        try
            if(~isnan(eval([param_this__ '{' num2str(i_test__) '}'])))
                error('Not NaN: assign battery param value!');
            end
        catch
            if(strcmp(param_this__, 'path_folders__') || strcmp(param_this__, 'feat_path__'))
                aux = 'volume_path';
            else
                aux = '';
            end
            eval([param_original__ ' = [' aux ' ' param_this__ '{' num2str(i_test__) '}];']);
        end
        
    end

    % Reload dynamic parameters
    if(strcmp(objectness.type, 'Ferrari'))
        run 'Objectness Ferrari/objectness-release-v2.2/startup'
    elseif(strcmp(objectness.type, 'MCG'))
        thispath = pwd;
        cd(objectness.pathMCG)
        run install
        cd(thispath)
    end

    results_folder = [tests_path '/ExecutionResults/' results_folder];
    mkdir(results_folder);
    
    % Run test
    main;
    disp(' ');disp(' ');
end

