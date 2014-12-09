function [ xmin, ymin, xmax, ymax ] = getObjectData( obj )

    xmin = 99999999;
    ymin = 99999999;
    xmax = -1;
    ymax = -1;

    pts = regexp(obj, '<pt>', 'split'); pts = {pts{2:end}};
    for pt = pts
        x = str2num(getElementXML(pt{1}, 'x'));
        y = str2num(getElementXML(pt{1}, 'y'));
        xmin = min(xmin, x);
        ymin = min(ymin, y);
        xmax = max(xmax, x);
        ymax = max(ymax, y);
    end
    
end

