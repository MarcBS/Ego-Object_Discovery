function [ hasEasy, v, p ] = getEasyObjects( objects, t, W, easiness_rate, all_indices)
%GETEASYOBJECTS Gets the easiest objects wrt their scores for the current
%iteration t.
%   Gets only the objects with a high enought score for being considered
%   easy. The easines depends on the iteration t.

    lenObjs = size(all_indices,1);

    %% Get all scores for all objects
    obj_scores = zeros(1, lenObjs);
    count = 1;
    countUnlabeled = 0;
    for ind = all_indices' % for each index
        this_scn = objects(ind(1));
        this_obj = objects(ind(1)).objects(ind(2));
        if(isfield(this_obj, 'label'))
            lab = this_obj.label;
        else % no label assigned
            lab = 0;
        end
        if(lab == 0) % Unlabeled sample
            countUnlabeled = countUnlabeled+1;
        end
        % Get its score
        if(isfield(this_scn, 'sceneAwareScore'))
            sceneAwareScore = this_scn.sceneAwareScore;
        else
            sceneAwareScore = 0;
        end
        obj_scores(count) = this_obj.objScore + this_obj.eventAwareScore + sceneAwareScore;
        count = count+1;
    end
    
    %% get positions of unlabeled samples
    U = zeros(countUnlabeled, 1); % stores the indices for the unlabeled samples
    count = 1; countFound = 1;
    for ind = all_indices' % for each index
        this_obj = objects(ind(1)).objects(ind(2));
        if(isfield(this_obj, 'label'))
            lab = this_obj.label;
        else % no label assigned
            lab = 0;
        end
        if(lab == 0) % Unlabeled sample
            U(countFound) = count;
            countFound = countFound+1;
        end
        count = count+1;
    end
    
    %% Sort them and get only the easiest
    [v,p] = sort(obj_scores, 2, 'descend');
    
    %% Get only the "easiest" objects, selecting them by a threshold
    easy = v >= (mean(v) + easiness_rate(1)*std(v)- abs(std(v))*easiness_rate(2)*t);
    p = p(easy);
    v = v(easy);
    
    %% Filter only the unlabeled ones
    [p, ind] = intersect(p, U, 'stable');
    p = p';
    v = v(ind);

    %% Get only the first easiness_rate(3) instances if too many
    if(length(v) > easiness_rate(3))
        v = v(1:easiness_rate(3));
        p = p(1:easiness_rate(3));
    end
    
    %% Show how many elements returns
    disp(['Returning top ' num2str(length(v)) ' easiest samples.']);
    
    hasEasy = ~isempty(v);
end

