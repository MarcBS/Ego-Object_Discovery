function [ P ] = exemplarBasedModel( w, cj )
%EXEMPLARBASEDMODEL Calculates the proportional probability value for the
%element w to belong to the same class of the elements in cj

    
    lenFeatures = length(w);
    nSamples = size(cj,1);
    
%     W = repmat(w,size(cj,1),1);
%     P = sum(bsxfun(@chi_squareKernel, W, cj))/lenFeatures;
    
    P = 0;
    
    %% Iterate over each possible feature
    for m = 1:lenFeatures
        
        %% Iterate over each sample
%         mSum = 0;
%         for l = 1:nSamples
%             mSum = mSum + chi_squareKernel( w(m), cj(l,m) );
%         end
        mSum = sum(chi_squareKernel2( cj(:,m), w(m)));
        P = P + mSum/nSamples;
        
    end
    P = P/lenFeatures;

end

