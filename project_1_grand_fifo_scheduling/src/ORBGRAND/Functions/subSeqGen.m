% =========================================================================
% Title       : Noise sub-sequence generation
% File        : subSeqGen.m
% -------------------------------------------------------------------------
% Generates all possible noise sub-sequences of length ni, reliability
% weight W and Hamming weight w according to [1]. Calls landslide with tot,
% wi and ni.
%
% [1] K. R. Duffy, W. An, and M. Médard, “Ordered reliability bits guessing
% random additive noise decoding,” IEEE Trans. Signal Process., vol. 70,
% pp. 4528–4542, 2022.
% =========================================================================


function [subSeqs] = subSeqGen(Wi, wi, ni, J, B)
    %Convert into into partition problem solvable by landslide
    tot = (Wi-wi*J) / B;
    tot_ = tot - wi*(wi+1)*0.5;
    n_ = ni - wi;

    [U] = landslide(tot_, wi, n_);

    %Adapt
    row = 1:size(U,2);
    adaptMatrix = repmat(row, size(U,1), 1);
    U = U + adaptMatrix;

    %Toggle bits
    subSeqs = false(size(U,1), ni);
    for j = 1:size(U,1)
        temp = false(1,ni);
        for c = 1:size(U,2)
            if U(j,c) ~= 0
                temp(1,U(j,c)) = true;
            end
        end

        subSeqs(j,:) = temp;
    end
end
