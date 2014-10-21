
addpath('../../');
% Location where all the tests results will be stored
tests_path = '../../../../../../Video Summarization Tests';

folder1 = [tests_path '/TestsObjectness/' 'Images_Narrative_Ferrari'];
name1 = 'Ferrari';
folder2 = [tests_path '/TestsObjectness/' 'Images_Narrative_BING'];
name2 = 'BING';

join_folder = [tests_path '/TestsObjectness/' 'Comparison_Narrative'];
mkdir(join_folder);

format = '.jpg';

images1 = dir([folder1 '/*' format]);
images2 = dir([folder2 '/*' format]);

for i = 1:length(images1)
    img1 = imread([folder1 '/' images1(i).name]);
    img2 = imread([folder2 '/' images2(i).name]);
    f=figure;
    h = tight_subplot(1,2,0,0,0);
    % Insert first images
    axes(h(1)); imshow(img1);
    title(name1);
    % Insert second image
    axes(h(2)); imshow(img2);
    title(name2);
    saveas(f, [join_folder '/img_' num2str(i)], 'jpg');
    close(gcf);
end