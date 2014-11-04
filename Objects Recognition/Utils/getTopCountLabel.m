function [ count ] = getTopCountLabel( objects, labName, notInit )
%GETTOPCOUNTLABEL Calculates the total number of labName true samples 
%existent in the dataset.

%     lenImages = length(objects);
%     count = 0;
%     for i = 1:lenImages
%         lenObjects = length(objects(i).objects);
%         for j = 1:lenObjects
%             if(isempty(objects(i).objects(j).initialSelection) && strcmp(objects(i).objects(j).trueLabel, labName))
%                 count = count+1;
%             end
%         end
%     end

    count = 0;
    for ind = notInit'
        if(strcmp(objects(ind(1)).objects(ind(2)).trueLabel, labName))
            count = count+1;
        end
    end

end

