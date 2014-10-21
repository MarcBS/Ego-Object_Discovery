function [ Sim ] = chi_squareSimilarities( A, E, S )%, C )
%CHI_SQUARESIMILARITIES Calculates the similarities of elements in A, E, S and C
%based on the chi-square kernel.
%   Calculates the matrix of similarities between the features in A
%   (apearance), E (event), S (scene) and C (context) using the chi-square kernel for all the 
%   samples in it.
%   Both matrices must have the same number of samples and stored as rows.
%   Max similarity = 2!!
%%%%

    N = size(A,1);
    Sim = zeros(N,N);
    for i = 1:N
        for j = (i+1):N
            s = chi_squareKernel(A(i,:), A(j,:)) + chi_squareKernel(E(i,:), E(j,:)) + chi_squareKernel(S(i,:), S(j,:));
            Sim(i,j) = s;
        end
    end
    Sim = sparse(Sim);
    
end

