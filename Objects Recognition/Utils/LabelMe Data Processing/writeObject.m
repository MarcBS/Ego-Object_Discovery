function writeObject( ann_f, obj, prop_res )

    fprintf(ann_f, '\t<object>\n');
    fprintf(ann_f, ['\t\t<name>' getElementXML(obj, 'name') '</name>\n']);
    occluded = getElementXML(obj, 'occluded');
    if(strcmp(occluded, 'no'))
        occluded = 0;
    else
        occluded = 1;
    end
    fprintf(ann_f, ['\t\t<occluded>' num2str(occluded) '</occluded>\n']);
    
    % Store points
    pts = regexp(obj, '<pt>', 'split'); pts = {pts{2:end}};
    for pt = pts
        x = max(1, round(str2num(getElementXML(pt{1}, 'x'))*prop_res));
        y = max(1, round(str2num(getElementXML(pt{1}, 'y'))*prop_res));
        fprintf(ann_f, '\t\t<pt>\n');
        fprintf(ann_f, ['\t\t\t<x>' num2str(x) '</x>\n']);
        fprintf(ann_f, ['\t\t\t<y>' num2str(y) '</y>\n']);
        fprintf(ann_f, '\t\t</pt>\n');
    end
    
    fprintf(ann_f, '\t</object>\n');

end

