% =========================================================================
% Title       : ORBGRAND decoder
% File        : ORBGRAND.m
% -------------------------------------------------------------------------
% ORBGRAND decoder as first introduced in [1].
%
% [1] K. R. Duffy, W. An, and M. Médard, “Ordered reliability bits guessing
% random additive noise decoding,” IEEE Trans. Signal Process., vol. 70,
% pp. 4528–4542, 2022.
% =========================================================================


function [bitHat, success, reqIts] = ORBGRAND(config, llrs)
    H = config.H;
    n = config.n;
    k = config.k;
    m = config.m;

    reqIts = 0;
    maxIt = config.max_iters; %Assumption: maxIt > 0

    %Hard decoding
    ydec = logical(1-(llrs>0));

    %Sort by ascending reliability
    [L, sortIdx] = sort(abs(llrs), 2, "ascend");
    
    %Calculate parameters
    [J, B, I] = getParams(config, L);

    %Maximal and minimal possible reliability weight of each section
    maxWi = zeros(m,1);
    for a = 1:m-1
        len = I(a+1)-I(a);
        inc = len*J(a) + B(a)*0.5*len*(len+1);
        maxWi(a) = maxWi(a) + inc;
    end
    minWi = J + B;

    %Initialize memoization
    [mem, bk_mem, firstFree_mem] = initMem(m, maxIt, I);

    %Main loop
    maxItersReached = false;
    W = 0;
    currIt = 0;

    %Treat uncorrupted case separately
    [bitHat, success] = tryNoise(ydec, zeros(1,n), sortIdx, H);
    currIt = currIt + 1;
    reqIts = currIt;
    if success == true
        return
    end

    %For the case that maxIt == 1
    if maxIt == currIt
        maxItersReached = true;
    end

    %Main loop
    while ~maxItersReached
        W = W + 1;

        %Get all splitting patterns
        Xi = intSplit(W, minWi, maxWi, m, maxIt);
        if isempty(Xi)
            continue
        end

        %For all Wm in Xi
        for wm_i = 1:size(Xi,1)
            Wm = Xi(wm_i,:);
            [psi, mem, bk_mem, validWm, firstFree_mem] = getPsi(Wm, J, B, I, mem, bk_mem, firstFree_mem);

            if ~validWm
                continue
            end
            
            remainingIts = maxIt - currIt;
            [nextNoises] = cartProd(psi, remainingIts, n);
           
            for rows = 1:size(nextNoises,1)

                [bitHat, success] = tryNoise(ydec, nextNoises(rows,:), sortIdx, H);
                
                if success
                    reqIts = currIt + 1;
                    return
                end

                currIt = currIt + 1;

                %All iterations executed
                if currIt == maxIt
                    maxItersReached = true;
                    break;
                end
            end

            if maxItersReached
                break;
            end
        end
    end

    %Executed if max_iters_reached
    bitHat = zeros(1,k); %Just to assign something
    success = false;
    reqIts = maxIt;
    return
end


%Initialize memory
function [mem, bk_mem, firstFree_mem] = initMem(m, maxIt, I)
    %NOTE: Memory is expanded as needed within psiCalc.m
    mem = cell(1,m);
    bk_mem = cell(1,m);
    firstFree_mem = ones(1,m);

    %To avoid excessive memory usage
    memSize = min(maxIt, 1e6); %Arbitrary

    mem{1} = false(memSize, I(2)-I(1));
    bk_mem{1} = inf(memSize, 1, 'single');

    %Subsequent intervals require substantially less rows
    for i = 2:m
        rowsNeeded = max(floor(memSize/(10^i)), 100);
        mem{i} = false(rowsNeeded, I(i+1)-I(i));
        bk_mem{i} = inf(rowsNeeded, 1, 'single');
    end
end

