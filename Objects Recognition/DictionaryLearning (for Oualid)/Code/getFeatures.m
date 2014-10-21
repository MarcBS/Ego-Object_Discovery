function [ features ] = getFeatures( objects, indices, path_features )
%GETFEATURES Extracts the LAB, pHOG and SPM features for the selected
%objects.
%  
%   Extracts all the features for the set of objects referenced by the
%   indices, where:
%   
%   INPUT
%       indices <Nx2 matrix> storing N rows with the information
%           [index_image index_object] which represents the index
%           of the desired objects in the structure "objects".
%       objects <struct> with the objects.mat structure loaded.
%       path_features <String> with the absolute path to the folder where
%           the features are stored ("Data PASCAL_07" folder).
%
%   OUTPUT
%       features <Nx4925 matrix> with each row representing the features of
%           the i-th object in the indices matrix. 
%
%%%

    addpath('auxCode/Vocabulary;auxCode/SpatialPyramidMatching;auxCode');

    %%%% Features extraction
    feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram
    feature_params.wSIFT = 16; % width of the patch used for SIFT calculation
    feature_params.dSIFT = 10; % distance between centers of each neighbouring patches
    feature_params.lHOG = 3; % number of levels used for the P-HOG
    feature_params.bHOG = 8; % number of bins used for the P-HOG

    %%%% Spatial Pyramid Matching
    feature_params.M = 200; % dimensionality of the vocabulary used
    feature_params.L = 2; % number of levels used in the SPM
    load('auxCode/Vocabulary/vocabulary.mat'); % load vocabulary "V"
    load('auxCode/Vocabulary/min_norm.mat');
    load('auxCode/Vocabulary/max_norm.mat');
    
    [features, ~] = recoverFeatures(objects, indices, zeros(1, size(indices,1)), V, V_min_norm, V_max_norm, [], feature_params, path_features, false, '', '');

end

