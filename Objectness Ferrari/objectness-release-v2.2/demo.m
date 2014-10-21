run startup
%imgExample = imread('002053.jpg');
imgExample = imread('/home/marc/Desktop/6FD1B048-A2F2-4CAB-1EFE-266503F59CD3/00002970.JPG');
imgExample = imresize(imgExample, [size(imgExample,1)/5 size(imgExample,2)/5]);
boxes = runObjectness(imgExample,50);
figure,imshow(imgExample),drawBoxes(boxes);