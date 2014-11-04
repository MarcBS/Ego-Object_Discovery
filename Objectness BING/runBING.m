function runBING( path_fold, model_name, mode, workingpath )
%RUNBING Interface for running BING Objectness.
%   Runs the BInarized Normed Gradients Objectness measure on all the
%   samples in "path_fold". We can also retrain the objectness using "mode"
%   = "train" instead of "test".
%
%   path_fold --> path to the folder where the images are stored. Its
%           |       format must be: 
%           |
%           |-- JPEGImages : all .jpg images
%           |
%           |-- Annotations : all .yml files with the bounding boxes
%           |                 annotated.
%           |
%           |-- names.txt : list of image names chosen from JPEGImages and
%           |               Annotations
%           |
%           |-- class.txt : list of classes present in the Annotations
%                           folder.
%
%   model_name --> name of the file where the trained model will be or is
%                   stored.
%
%   mode --> 'train' or 'testval'.
%
%   workingpath --> folder where both the model and the results will be
%                   stored. If workingpath == '' a new folder 'WkDir' will
%                   be created in this directory.
%
%%

    if(strcmp(workingpath, ''))
        workingpath = 'D:\Documentos\Dropbox\Video Summarization Project\Code\Objectness BING/WkDir/';
    end
    
    if(~strcmp(mode, 'train') && ~strcmp(mode, 'testval'))
        error(['Wrong mode "' mode '" !']);
    end

    path_exe = 'D:\Documentos\Dropbox\Video Summarization Project\Code\Objectness BING\BingObjectnessCVPR14\x64\Release\Objectness.exe';

    system(['"' path_exe '" "' mode '" "' workingpath '" "' path_fold '" "' model_name '"']);

end

