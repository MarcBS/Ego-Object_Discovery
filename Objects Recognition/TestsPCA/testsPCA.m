
addpath('../Utils');

%% Parameters definition
% Fraction of minimum variance we want to keep
minVar = 0.99;
colors = [1 0 0; 0 1 0; 0 0 1];

%% Load data
load iris.dat
features = iris;
labels = features(:,end);
uniqueLabels = unique(labels);

%% Apply PCA
features = standarize(features(:,1:end-1));
[COEFF, ~, latent] = princomp(features);

%% Get variables with a minimum of minVar of the variance
dim = 0; var = 0;
while(minVar > var)
    dim = dim+1;
    var = sum(latent(1:dim))/sum(latent);
end

%% Transform features with new dimensionality
new_features = features*COEFF(:,1:dim);

%% Plot result
f = figure;
for l = uniqueLabels'
    scatter3(new_features(find(labels==l),1), new_features(find(labels==l),2), new_features(find(labels==l),3), 10, colors(l,:));
    hold on;
end

disp('Done');