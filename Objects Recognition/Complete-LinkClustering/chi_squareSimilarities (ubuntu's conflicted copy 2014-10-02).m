function [ S ] = chi_squareSimilarities( A, E)%, C )
%CHI_SQUARESIMILARITIES Calculates the similarities of elements in A, E and C
%based on the chi-square kernel.
%   Calculates the matrix of similarities between the features in A
%   (apearance), E (event) and C (context) using the chi-square kernel for all the 
%   samples in it.
%   Both matrices must have the same number of samples and stored as rows.
%   Max similarity = 2!!
%%%%

    N = size(A,1);
    S = zeros(N,N);
    for i = 1:N
        for j = (i+1):N
            s = chi_squareKernel(A(i,:), A(j,:)) + chi_squareKernel(E(i,:), E(j,:));
            S(i,j) = s;
        end
    end
    S = sparse(S);
    
end

