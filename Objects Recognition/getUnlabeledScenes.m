function [ pos ] = getUnlabeledScenes( objects )
%GETUNLABELEDSCENES Returns all the indices to the unlabeled scenes.

    lenScenes = length(objects);
    pos = [];
    for i = 1:lenScenes
        try
            if(isempty(objects(i).labelSceneRuntime))
                pos = [pos; i];
            end
        catch
            break;
        end
    end

end

