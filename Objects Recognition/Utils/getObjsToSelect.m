function [ toSelect ] = getObjsToSelect( indices, objects, feature_params )
%GETOBJSTOSELECT Selects the "selectable" objects, taking into account
% the percentage of object classes kept aside and the percentage of maximum
% objects selected.
    
    %% Finds the classes of all objects
    nSamples = size(indices,1);
    all_classes = cell(nSamples,1);
    for i = 1:nSamples
        all_classes{i} = objects(indices(i,1)).objects(indices(i,2)).trueLabel;
    end
    unique_classes = unique(all_classes);
    classes_obj = ~ismember(unique_classes, 'No Object');
    
    %% Gets the set of classes that can be selected
    nClasses = length(unique_classes)-1;
    sel_classes = randsample(find(classes_obj), round(nClasses*(1-feature_params.initialObjectsClassesOut)));
    sel_classes = [sel_classes; find(~classes_obj)]; % add 'No Object' class
    sel_objects = zeros(nSamples, 1);
    for i = 1:length(sel_classes)
        sel_objects = sel_objects + ismember(all_classes,unique_classes{sel_classes(i)});
    end
    sel_objects = find(sel_objects);
    nSelObjects = length(sel_objects);
    
    %% Gets the set of samples that can be selected
    nGetObjects = round(nSamples * feature_params.initialObjectsPercentage);
    nGetObjects = min(nGetObjects, nSelObjects);
    
    %% Gets final samples selection
    toSelect = randsample(sel_objects, nGetObjects)';
    
    classes = unique_classes{sel_classes(1)};
    for i = 2:length(sel_classes)
        classes = [classes ', ' unique_classes{sel_classes(i)}];
    end
    disp(['Classes selected: {' classes '}']);
end

