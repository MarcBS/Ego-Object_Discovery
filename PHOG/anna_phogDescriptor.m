function p = anna_PhogDescriptor(bh,bv,L,bin)
% anna_PHOGDESCRIPTOR Computes Pyramid Histogram of Oriented Gradient over a ROI.
%               
%IN:
%	bh - matrix of bin histogram values
%	bv - matrix of gradient values 
%   L - number of pyramid levels
%   bin - number of bins
%
%OUT:
%	p - pyramid histogram of oriented gradients (phog descriptor)

% Initialize p to 0s for quicker filling of array
np = 0; for i = 0:L; np = np + 4^i * bin; end
p = zeros(np,1);
countp = 1;

%level 0
for b=1:bin
    ind = bh==b;
    p(countp) = sum(bv(ind));
    countp = countp+1;
end
        
cella = 1;
for l=1:L
    x_vals = fix(linspace(0,size(bh,2),2^l+1));
    y_vals = fix(linspace(0,size(bh,1),2^l+1));
    cx = 1; % count x position
    for xx = x_vals(1:end-1)
        cy = 1; % count y position
        for yy = y_vals(1:end-1)
            bh_cella = [];
            bv_cella = [];
            
            bh_cella = bh(yy+1:y_vals(cy+1),xx+1:x_vals(cx+1));
            bv_cella = bv(yy+1:y_vals(cy+1),xx+1:x_vals(cx+1));
            
            for b=1:bin
                ind = bh_cella==b;
                p(countp) = sum(bv_cella(ind));
                countp = countp+1;
            end 
            cy = cy+1;
        end        
        cella = cella+1;
        cx = cx+1;
    end
end
if sum(p)~=0
    p = p/sum(p);
end

