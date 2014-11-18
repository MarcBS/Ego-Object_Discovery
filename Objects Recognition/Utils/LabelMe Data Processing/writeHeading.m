function writeHeading( ann_f, folder, filename )

    fprintf(ann_f, '<annotations>\n');
    fprintf(ann_f, ['\t<folder>' folder{1} '</folder>\n']);
    fprintf(ann_f, ['\t<filename>' filename '</filename>\n']);
    fprintf(ann_f, '\t<author>\n');
    fprintf(ann_f, ['\t\t<name>Marc Bola~nos</name>\n']);
    fprintf(ann_f, ['\t\t<email>marc.bolanos@ub.edu</email>\n']);
    fprintf(ann_f, ['\t\t<institution>Universitat de Barcelona</institution>\n']);
    fprintf(ann_f, '\t</author>\n');

end

