% =========================================================================
% Title       : Produces the cartesian product of an appropriate size.
% File        : cartProd.m
% -------------------------------------------------------------------------
% Generates the cartesian product among psis. As return value 'nextNoises'
% can get very large, 'remainingIts' ensures that only the necessary noises
% are computed. Parametrized to work with any segment number m.
% =========================================================================


function [nextNoises] = cartProd(psi, remainingIts, n)
    %m = 1 as special case
    if numel(psi) == 1
        nextNoises = psi{1};
        return;
    end

    %Preallocate nextNoises
    nextNoises_rows = size(psi{1},1);
    for i = 2:numel(psi)
        nextNoises_rows = nextNoises_rows*size(psi{i},1);
    end
    nextNoises = false(nextNoises_rows,n);


    rows = 1;
    level = 1;
    for row1 = 1:size(psi{1},1)
        [nextNoises, rows, stop] = rec(psi, level+1, psi{1}(row1,:), nextNoises, remainingIts, rows);
        if stop
            nextNoises = nextNoises(1:rows,:);
            return;
        end
    end
    
    %Delete unused rows
    nextNoises = nextNoises(1:rows-1,:);
end



function [nextNoises, rows, stop] = rec(psi, level, singleNoise, nextNoises, remainingIts, rows)
    stop = false;

    %If last psi cell reached
    if level == numel(psi)
        for psi_row = 1:size(psi{level},1)
            singleNoise_next = [singleNoise, psi{level}(psi_row,:)];
            nextNoises(rows,:) = singleNoise_next;
            
            if rows == remainingIts
                stop = true;
                nextNoises = nextNoises(1:rows,:);
                return
            end

            rows = rows + 1;
        end
    else
        for psi_row = 1:size(psi{level},1)
            singleNoise_next = [singleNoise, psi{level}(psi_row,:)];
            [nextNoises, rows, stop] = rec(psi, level+1, singleNoise_next, nextNoises, remainingIts, rows);

            if stop
                return
            end
        end
    end
end
















