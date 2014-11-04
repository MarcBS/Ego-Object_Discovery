function [ labels ] = getLabels( gt_im, classes, valid_classes, version )
%GETLABELS Finds the unique object labels from a ground truth segmentation
%   image of the MSRC Dataset.

    labels = [];

    if(version == 1)
        valid_classes = find(valid_classes);
    end
    gt_array = reshape(gt_im, [1 size(gt_im,1)*size(gt_im,2)]);
    both = intersect(gt_array, valid_classes);
    
    count = 1;
    if(both)
        for class = both'
            % Get pixels with this label
            this_gt = gt_im==class;

            % Get continuous segmentations with the same label separated
            this_gt = bwlabel(this_gt);

            % Get unique objects
            labs = unique(this_gt);
            labs = labs(2:end);

            for l = labs'
                labels(count).name = classes{class};
                nRows = size(this_gt,1);
                nCols = size(this_gt,2);

                lab_gt = this_gt==l;

                % Find Y positions
                first = true;
                last = true;
                i = 1;
                while(first || last)
                    if(first)
                        if(sum(lab_gt(i,:)) > 0)
                            % Found minY position
                            labels(count).ULy = i;
                            first = false;
                        end
                    elseif(last)
                        if(i >= nRows)
                            labels(count).BRy = nRows;
                            last = false;
                        elseif(sum(lab_gt(i,:)) == 0)
                            % Found maxY position
                            labels(count).BRy = i-1;
                            last = false;
                        end
                    end
                    i = i+1;
                end

                % Find X positions
                first = true;
                last = true;
                i = 1;
                while(first || last)
                    if(first)
                        if(sum(lab_gt(:,i)) > 0)
                            % Found minY position
                            labels(count).ULx = i;
                            first = false;
                        end
                    elseif(last)
                        if(i >= nCols)
                            labels(count).BRx = nCols;
                            last = false;
                        elseif(sum(lab_gt(:,i)) == 0)
                            % Found maxY position
                            labels(count).BRx = i-1;
                            last = false;
                        end
                    end
                    i = i+1;
                end

                count = count+1;
            end
        end
    end

end

