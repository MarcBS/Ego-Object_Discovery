
%% This file can be used as an interface to run the BING objectness


%%%% Parameters

mode = 'testval'; % 'train' or 'testval'

% workingpath = 'D:/Video Summarization Project Data Sets/PASCAL_BING/WkDir/';
workingpath = 'D:\Documentos\Dropbox\Video Summarization Project\Code\Objectness BING/WkDir/';
trainpath = 'D:/Video Summarization Project Data Sets/PASCAL_BING/Train Data/';
testpath = 'D:/Video Summarization Project Data Sets/PASCAL_BING/Test Data/';
model_name = 'modelTrained.txt';

path_exe = 'D:\Documentos\Dropbox\Video Summarization Project\Code\Objectness BING\BingObjectnessCVPR14\x64\Release\Objectness.exe';


%%%% Execution

if(strcmp(mode, 'train'))
    path_fold = trainpath;
elseif(strcmp(mode, 'testval'))
    path_fold = testpath;
else
    error(['Wrong mode "' mode '" !']);
end

system(['"' path_exe '" "' mode '" "' workingpath '" "' path_fold '" "' model_name '"']);
