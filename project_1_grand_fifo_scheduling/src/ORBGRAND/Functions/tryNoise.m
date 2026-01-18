% =========================================================================
% Title       : Codebook checker and final decoding
% File        : tryNoise.m
% -------------------------------------------------------------------------
% Checks if putative noise subtraction results in a valid codeword.
% =========================================================================


function [decoded_output, success] = tryNoise(y_dec, nextNoise, sort_idx, H)
    %Desort
    currNoise(1,sort_idx) = nextNoise;

    %Try possible codeword
    candidate = xor(y_dec, currNoise);
    parity_check = mod(H*candidate', 2);
    if sum(parity_check) == 0
        decoded_output = candidate(1,1:(size(H,2) - size(H,1)));
        success = true;
    else
        decoded_output = false(1,(size(H,2) - size(H,1)));
        success = false;
    end
end