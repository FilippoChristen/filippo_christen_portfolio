% =========================================================================
% Title       : Valid Hamming Weight set finder
% File        : validHamm.m
% -------------------------------------------------------------------------
% For each partial reliability weight Wi of each splitting pattern Wn,
% this function finds the set of all possible Hamming weights that the
% noise subsequence of the segment i can have. If none are possible, it
% returns possible == false. This will be dealt with in parent function, 
% and invalidates the whole splitting pattern Wn.
% This function implements algorithm 4 from [1].
%
% Note: Bi, Li indexes like paper, while Ii, Ji are +1 here.
%
% [1] K. R. Duffy, W. An, and M. Médard, “Ordered reliability bits guessing
% random additive noise decoding,” IEEE Trans. Signal Process., vol. 70,
% pp. 4528–4542, 2022.
% =========================================================================


function [H_Wi, possible] = validHamm(Wi, J, B, Ii, Iii)
    k = 0;
    maxHamm = floor(0.5*(sqrt(1+8*Wi)-1));
    possible = true;

    H_Wi = zeros(maxHamm,1);
    for w = 0:maxHamm
        validWi = valid(Wi, w, J, B, Ii, Iii);
        if validWi
            k = k+1;
            H_Wi(k,1) = w;
        end
    end

    if k == 0
        possible = false;
        H_Wi = [];               
        return
    end

    %Remove unused rows
    H_Wi = H_Wi(1:k,1);
end


%Check conditions (15)
function [possible] = valid(W, w, J, B, Ii, Iii)
    if((W == 0) || ((W-w*J) >= 0.5*B*(1+w)*w))
        if((W-w*J) <= B*((Iii-Ii+1)*w - 0.5*(1+w)*w))
            if(mod(W-w*J, B) == 0)
                possible = true;
                return
            end
        end
    end

    possible = false;
end

