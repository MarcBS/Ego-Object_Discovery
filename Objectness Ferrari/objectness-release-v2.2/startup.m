addpath([pwd '/']);
addpath([pwd '/MEX/']);
display('Loading the default parameters ...');
params = defaultParams([pwd '/']);
save([pwd '/Data/params.mat'], 'params');