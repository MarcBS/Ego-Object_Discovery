function writeToFile( fid, data, toFile )

    % Writes to screen
    disp(data);
    
    % Writes to file if asked to
    if(toFile)
        % String
        if(strcmp(class(data), 'char'))
            fprintf(fid, '%s', data);
        elseif(strcmp(class(data), 'double'))
            dim = size(data);
            % Normal number
            if(length(dim) == 2 && dim(1) == 1 && dim(2) == 1)
                fprintf(fid, '%5.4f', data);
            % 2D matrix
            elseif(length(dim) == 2)
                for i = 1:dim(1)
                    fprintf(fid, '%8.4f', data(i,:));
                    fprintf(fid, '\n');
                end
            % 3D matrix
            elseif(length(dim) == 3)
                for j = 1:dim(3)
                    fprintf(fid, 'Layer %d', j);
                    for i = 1:dim(1)
                        fprintf(fid, '%8.4f', data(i, :, j));
                        fprintf(fid, '\n');
                    end
                    fprintf(fid, '\n');
                end
            end
            % doesn't print matrices with more than 3 dimensions
        % Cell
        elseif(strcmp(class(data), 'cell'))
            for i = 1:length(data)
                % Number in cell
                if(strcmp(class(data{i}), 'double'))
                    fprintf(fid, '%5.4f ', data{i});
                % String in cell
                elseif(strcmp(class(data{i}), 'char'))
                    fprintf(fid, '%s\n', data{i});
                end
            end
        end
        fprintf(fid, '\n');
    end

end

