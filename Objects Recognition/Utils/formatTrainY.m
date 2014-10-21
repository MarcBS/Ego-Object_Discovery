function [ trainY ] = formatTrainY( foundLabels, trainX_ind )
%FORMATTRAINY Formats a cell of training samples indices indexed by their
%resulting label into an array of class indices ordered by their sample index.

    trainY = zeros(size(trainX_ind,1), 1);
    for i = 1:length(foundLabels)
        if(~isempty(foundLabels{i}))
            trainY(foundLabels{i}) = i;
        end
    end

end

