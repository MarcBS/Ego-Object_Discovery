function out = random_selection(f, n)
% Written by L. Garrido

perm = randperm(size(f,2)) ;
sel = perm(1:n) ;
out = f(:,sel);