function [ histClasses, objects ] = extractEventAwareness( objects, classes, list_event, W )
%EXTRACTEVENTAWARENESS Extracts event awareness histogram and awareness
%score.
%   Detailed explanation goes here

    lenImgs = size(objects,2);

    %% Extract event awareness (shared over all the objects in the same event)
    % we get all the objects detected in each event
    nEvents = list_event(end);
    histClasses = zeros(nEvents, size(classes,2)); % histogram of objects for each event
    for i = 1:lenImgs % for each image
        for j = 1:W % for each window
            % Increment number of objects found for each class and
            % each event.
            if(length(objects(i).objects) >= j)
                try
                    nObj = histClasses(objects(i).idEvent, objects(i).objects(j).label+1);
                    histClasses(objects(i).idEvent, objects(i).objects(j).label+1) = nObj +1;
                catch % no label assigned
                    nObj = histClasses(objects(i).idEvent, 1); 
                    histClasses(objects(i).idEvent, 1) = nObj +1;
                end
            else
                break;
            end
        end
    end
    % Normalize histograms
    histClasses = normalizeHistograms(histClasses);
    
    %% Save event awareness score for each object
    for i = 1:lenImgs % for each image
        this_hist = histClasses(objects(i).idEvent,:);
        this_sum = sum(this_hist(2:end));
        for j = 1:W % for each window
            % We calculate the score as the accumulated sum of all the
            % histogram values corresponding to the current object but the
            % initial one, which represents not analyzed object candidates.
            if(length(objects(i).objects) >= j)
                objects(i).objects(j).eventAwareScore = this_sum;
            else
                break;
            end
        end
    end

end

