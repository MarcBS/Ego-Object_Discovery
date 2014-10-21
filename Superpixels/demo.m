tic
im = imread('00000014.JPG');

[l, Am, C] = slic(im, 100, 10, 1, 'mean');
lc = spdbscan(l, C, Am, 5);
imshow(drawregionboundaries(lc, im, [255 255 255]));

toc