function runBINGNoValidation( img_path, format, workingpath, prop_res )
%RUNBING Interface for running BING Objectness.
%   Runs the BInarized Normed Gradients Objectness measure on set of
%   samples in "img_path".
%%

    model_name = 'modelTrained.txt';
    local_path = regexp(pwd, '\', 'split'); root_path = '';
    for i = 1:length(local_path)-1
        root_path = [root_path local_path{i} '/'];
    end
    path_exe = [root_path 'Objectness BING/BingObjectnessCVPR14/x64/Release/Objectness.exe'];

    % Get all images
    images = dir([img_path '*' format]);
    f = fopen([img_path 'names.txt'], 'w');
    lenImgs = length(images);
    for i = 1:lenImgs;
        im_name = images(i).name;
        im_name = regexp(im_name, '\.', 'split');
        im_name = im_name{1};
        fprintf(f, '%s\n', im_name);
    end
    fclose(f);
    
    system(['"' path_exe '" "test" "' workingpath '" "' img_path '" "' model_name '" "' num2str(prop_res) '"']);
    
end

