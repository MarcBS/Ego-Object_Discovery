% Runs the superpixel code on the lizard image

addpath('lsmlib');
img = im2double(imread('lizard.jpg'));
[phi,boundary,disp_img,indexed] = superpixels2(img, 2000);
imagesc(disp_img);
