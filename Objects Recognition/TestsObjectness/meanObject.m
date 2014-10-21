function [ mean_obj ] = meanObject( objs, types )
%MEANOBJECT Gets the mean object of the candidates passed by parameter

    len = length(objs);
    vals = zeros(len, 5);
    for i = 1:len
        
        if(strcmp(types{i}, 'Ferrari'))
            vals(i,1) = objs{i}.objScore;
        elseif(strcmp(types{i}, 'BING'))
            vals(i,1) = 1+objs{i}.objScore;
        end
        
        vals(i,2) = objs{i}.ULx;
        vals(i,3) = objs{i}.ULy;
        vals(i,4) = objs{i}.BRx;
        vals(i,5) = objs{i}.BRy;
    end
    
    mean_obj = mean(vals);

end

