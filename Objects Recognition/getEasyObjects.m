function [ hasEasy, v, p ] = getEasyObjects( objects, t, W, easines_rate, all_indices)
%GETEASYOBJECTS Gets the easiest objects wrt their scores for the current
%iteration t.
%   Gets only the objects with a high enought score for being considered
%   easy. The easines depends on the iteration t.

    lenObjs = size(all_indices,1);

    %% Get all scores for all objects
    obj_scores = zeros(1, lenObjs);
    U = []; % stores the indices for the unlabeled samples
    count = 1;
    for ind = all_indices' % for each index
        try
            lab = objects(ind(1)).objects(ind(2)).label;
        catch % no label assigned
            lab = 0;
        end
        if(lab == 0) % Unlabeled sample
            U = [U; count];
        end
        % Get its score
        try
            sceneAwareScore = objects(ind(1)).sceneAwareScore;
        catch
            sceneAwareScore = 0;
        end
        obj_scores(count) = objects(ind(1)).objects(ind(2)).objScore + objects(ind(1)).objects(ind(2)).eventAwareScore + sceneAwareScore;
        count = count+1;
    end
    
    %% Sort them and get only the easiest
    [v,p] = sort(obj_scores, 2, 'descend');
    
    %% Get only the "easiest" objects, selecting them by a threshold
    easy = v >= (mean(v) + easines_rate(1)*std(v)- abs(std(v))*easines_rate(2)*t);
    p = p(easy);
    v = v(easy);
    
    %% Filter only the unlabeled ones
    [p, ind] = intersect(p, U, 'stable');
    p = p';
    v = v(ind);

    %% Get only the first easines_rate(3) instances if too many
    if(length(v) > easines_rate(3))
        v = v(1:easines_rate(3));
        p = p(1:easines_rate(3));
    end
    
    %% Show how many elements returns
    disp(['Returning top ' num2str(length(v)) ' easiest samples.']);
    
    if(length(v) > 0)
        hasEasy = true;
    else
        hasEasy = false;
    end
end

