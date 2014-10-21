
%% Parameters: paths to annotation folders
sourceAnno = 'D:\Documentos\Dropbox\Video Summarization Project\Code\Objectness BING\BingObjectnessCVPR14\VOC2007\Annotations';
destTrain = 'D:\Video Summarization Project Data Sets\PASCAL_BING\Train Data\Annotations';
destTest = 'D:\Video Summarization Project Data Sets\PASCAL_BING\Test Data\Annotations';


%% Get lists of annotations
listTrain = dir([destTrain '/*.xml']);
listTest = dir([destTest '/*.xml']);

%% Move Train annotations
lenTrain = length(listTrain);
for i = 1:lenTrain
    name = regexp(listTrain(i).name, '\.', 'split');
    name_all = [name{1} '.yml'];
    copyfile([sourceAnno '/' name_all], [destTrain '/' name_all]);
end


%% Move Test annotations
lenTest = length(listTest);
for i = 1:lenTest
    name = regexp(listTest(i).name, '\.', 'split');
    name_all = [name{1} '.yml'];
    copyfile([sourceAnno '/' name_all], [destTest '/' name_all]);
end

disp('Done');
