function [ notInit ] = getSamplesNotInitialSelection( objects )
%GETSAMPLESNOTINITIALSELECTION Finds the indices to the not initially 
%   selected samples.

    nNotInit = 0;
    nImgs = length(objects);
    for i = 1:nImgs
        nObj = length(objects(i).objects);
        for j = 1:nObj
            if(isempty(objects(i).objects(j).initialSelection))
                nNotInit = nNotInit+1;
            end
        end
    end
    
    notInit = zeros(nNotInit,2);
    count = 1;
    for i = 1:nImgs
        nObj = length(objects(i).objects);
        for j = 1:nObj
            if(isempty(objects(i).objects(j).initialSelection))
                notInit(count,:) = [i j];
                count = count+1;
            end
        end
    end

end

