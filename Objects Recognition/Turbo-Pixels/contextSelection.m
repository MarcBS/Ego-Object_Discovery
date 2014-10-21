% Selects the R closest superpixels for each object candidate

%% Parameters
volume_path = 'D:';
% volume_path = '/Volumes/SHARED HD';

R = 20;
prop_res = 4;
feat_path = [volume_path '/Video Summarization Objects/Features/Data SenseCam 0BC25B01'];
path_folders = [volume_path '/Documentos/Vicon Revue Data'];
folders = {'0BC25B01-7420-DD20-A1C8-3B2BD6C87CB0', '16F8AB43-5CE7-08B0-FD11-BA1E372425AB', ...
    '2E1048A6ECT', '5FA739A3-AAC4-E84B-F7CB-2179AD879AE3', '6FD1B048-A2F2-4CAB-1EFE-266503F59CD3' ...
    '819DC958-7BFE-DCC8-C792-B54B9641AA75', '8B6E4826-77F5-66BF-FCBA-4054D0E84B0B', ...
    'A06514ED-60B5-BF77-5549-2ED885FD7788', 'B07CCAA9-FEBF-E8F3-B637-B021D652CA48', ...
    'D3B168F2-40C8-7BAB-5DA2-4577404BAC7A'};
format = '.JPG';

addpath('../Utils');

%% Load objects and superpixels
disp('# LOADING OBJECTS FILE and SUPERPIXELS FILE...');
load([feat_path '/objects.mat']);
load([feat_path '/superpixels.mat']);

% Variable for storing the context selection performed over each object
% candidate for the closest top and bottom superpixels
context_selection = [];

nImages = length(objects);
for i = 1:nImages
    nObjects = length(objects(i).objects);
    sup = superpixels(i,:);
    for j = 1:nObjects
        %% Finds the closest superpixels at the top and at the bottom of
        % each object candidate
        top_sup = []; bot_sup = []; top_i = 1; bot_i = 1;
        obj = objects(i).objects(j);
        center = [(obj.ULy + obj.BRy)/2 (obj.ULx + obj.BRx)/2];
        nSup = length(sup);
        for k = 1:nSup
            %% If there is a superpixel in this position
            if(~isempty(sup(k).center))
                if(center(1) > sup(k).center(1))
                    % It is at the top
                    top_sup(top_i).dist = euclidDist(center, sup(k).center);
                    top_sup(top_i).idx = k;
                    top_i = top_i+1;
                elseif(center(1) < sup(k).center(1))
                    % It is at the bottom
                    bot_sup(bot_i).dist = euclidDist(center, sup(k).center);
                    bot_sup(bot_i).idx = k;
                    bot_i = bot_i+1;
                end
            end
        end
        
        %% Sorts the superpixels by proximity and stores the first R
        % Top
        if(~isempty(top_sup))
            [~, pos] = sort([top_sup(:).dist]);
            r_sel = min(R, length(pos));
            top_sup = top_sup(pos(1:r_sel));
        else
            top_sup = [];
        end
        
        % Bottom
        if(~isempty(bot_sup))
            [~, pos] = sort([bot_sup(:).dist]);
            r_sel = min(R, length(pos));
            bot_sup = bot_sup(pos(1:r_sel));
        else
            bot_sup = [];
        end
        
        context_selection(i,j).top = top_sup;
        context_selection(i,j).bottom = bot_sup;
        
        %% Draw result (debugging)
%         drawContextSelection(i, j, objects, superpixels, context_selection, path_folders, prop_res);
    end
    
    %% Show progress
    if(mod(i,50)==0)
        disp(['Context selected on ' num2str(i) '/' num2str(nImages) ' images.']);
    end
    
end
disp(['Context selected on ' num2str(i) '/' num2str(nImages) ' images.']);

%% Save result
save([feat_path '/context_selection.mat'], 'context_selection');
