% =========================================================================
% Title       : Finds the set of all possible splitting patterns
% File        : intSplit.m
% -------------------------------------------------------------------------
% Finds all splitting patterns Wm through algorithm 3 from [1].
% Impossible integer splits are pruned.
%
% [1] K. R. Duffy, W. An, and M. Médard, “Ordered reliability bits guessing
% random additive noise decoding,” IEEE Trans. Signal Process., vol. 70,
% pp. 4528–4542, 2022.
% =========================================================================


function [Xi] = intSplit(W, minWi, maxWi, m, maxIt)
    switch m
        case 1
            Xi = W;
        case 2
            [Xi] = intSplit2(W, minWi, maxWi);
        case 4
            [Xi] = intSplit4(W, minWi, maxWi, maxIt);
        case 8
            [Xi] = intSplit8(W, minWi, maxWi, maxIt);
        otherwise
            error("m value not supported by intSplit.");
    end
end



function [Xi] = intSplit2(W, minWi, maxWi)
    Xi = zeros(W,2);

    i = 0;
    for W1 = 0:W
        if (W1 == 0 || W1 >= minWi(1)) && (W1 <= maxWi(1))
            W2 = W - W1;
            if (W2 == 0 || W2 >= minWi(2)) && (W2 <= maxWi(2))
                i = i+1;
                Xi(i,:) = [W1,W2];
            end
        end
    end

    %Delete all rows that where not used
    Xi = Xi(1:i,:);
end



function [Xi] = intSplit4(W, minWi, maxWi, maxIt)
    Xi_extension = 1e6; %Arbitrary

    %Worth it when maxIt << Xi_extension and W small
    XiTotalRows = min(Xi_extension, maxIt);
    Xi = zeros(XiTotalRows,4);

    i = 0;
    for W1 = 0:W
        if (W1 == 0 || W1 >= minWi(1)) && (W1 <= maxWi(1))
            for W2 = 0:(W-W1)
                if (W2 == 0 || W2 >= minWi(2)) && (W2 <= maxWi(2))
                    for W3 = 0:(W-(W1+W2))
                        if (W3 == 0 || W3 >= minWi(3)) && (W3 <= maxWi(3))
                            W4 = W - (W1+W2+W3);
                            if (W4 == 0 || W4 >= minWi(4)) && (W4 <= maxWi(4))
                                i = i+1;
                                Xi(i,:) = [W1,W2,W3,W4];

                                %Extend
                                if i == size(Xi,1)
                                    Xi = [Xi; zeros(Xi_extension,4)];
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    %Delete all rows that where not used
    Xi = Xi(1:i,:);
end



function [Xi] = intSplit8(W, minWi, maxWi, maxIt)
    Xi_extension = 1e6; %Arbitrary

    %Worth it when maxIt << Xi_extension and W small
    XiTotalRows = min(Xi_extension, maxIt);
    Xi = zeros(XiTotalRows,8);

    i = 0;
    for W1 = 0:W
        if (W1 == 0 || W1 >= minWi(1)) && (W1 <= maxWi(1))
            for W2 = 0:(W-W1)
                if (W2 == 0 || W2 >= minWi(2)) && (W2 <= maxWi(2))
                    for W3 = 0:(W-(W1+W2))
                        if (W3 == 0 || W3 >= minWi(3)) && (W3 <= maxWi(3))
                            for W4 = 0:(W-(W1+W2+W3))
                                if (W4 == 0 || W4 >= minWi(4)) && (W4 <= maxWi(4))
                                    for W5 = 0:(W-(W1+W2+W3+W4))
                                        if (W5 == 0 || W5 >= minWi(5)) && (W5 <= maxWi(5))
                                            for W6 = 0:(W-(W1+W2+W3+W4+W5))
                                                if (W6 == 0 || W6 >= minWi(6)) && (W6 <= maxWi(6))
                                                    for W7 = 0:(W-(W1+W2+W3+W4+W5+W6))
                                                        if (W7 == 0 || W7 >= minWi(7)) && (W7 <= maxWi(7))
                                                            W8 = W - (W1+W2+W3+W4+W5+W6+W7);
                                                            if (W8 == 0 || W8 >= minWi(8)) && (W8 <= maxWi(8))
                                                                i = i+1;
                                                                Xi(i,:) = [W1,W2,W3,W4,W5,W6,W7,W8];
                                                                
                                                                %Extend
                                                                if i == size(Xi,1)
                                                                    Xi = [Xi; zeros(Xi_extension,8)];
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    %Delete all rows that where not used
    Xi = Xi(1:i,:);
end
