function runBINGNoValidation( img_path, format, workingpath )
%RUNBING Interface for running BING Objectness.
%   Runs the BInarized Normed Gradients Objectness measure on set of
%   samples in "img_path".
%%

    model_name = 'modelTrained.txt';
    path_exe = 'D:/Documentos/Dropbox/Video Summarization Project/Code/Objectness BING/BingObjectnessCVPR14/x64/Release/Objectness.exe';

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
    
    system(['"' path_exe '" "' workingpath '" "' img_path '" "' model_name '"']);
    
end

