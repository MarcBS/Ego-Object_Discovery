function [ element ] = getElementXML( txt, id )

    element = regexp(txt, ['<' num2str(id) '>'], 'split');
    element = regexp(element{2}, ['</' num2str(id) '>'], 'split');
    element = element{1};

end

