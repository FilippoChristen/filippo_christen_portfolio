% =========================================================================
% Title       : Psi calculation.
% File        : getPsi.m
% -------------------------------------------------------------------------
% Returns the appropriate psi for a given splitting pattern according to [1].
% Memoization is applied.
%
% [1] K. R. Duffy, W. An, and M. Médard, “Ordered reliability bits guessing
% random additive noise decoding,” IEEE Trans. Signal Process., vol. 70,
% pp. 4528–4542, 2022.
% =========================================================================


function [psi, mem, bk_mem, validWm, firstFree_mem] = getPsi(Wm, J, B, I, mem, bk_mem, firstFree_mem)
    m = numel(mem);
    psi = cell(1,m);

    %Initialize
    for i = 1:m
        psi{i} = 0;
    end

    if m == 1 %Saving is not useful in this case
        [psi{1}, validWm] = psiCalc(Wm(1,1), J(1), B(1), I(1), I(1+1));
        if ~validWm
            return
        end
    else
        for curr_m = 1:m
            %Retrieve matching rows
            psi_rows = bk_mem{curr_m}(1:firstFree_mem(1,curr_m)-1,1) == Wm(1,curr_m);
            
            %Check if have to calculate psi
            calculate_psi = (sum(psi_rows) == 0);
            
            %Calculation will determine validWm
            validWm = true;
            if calculate_psi
                [psi{curr_m}, validWm] = psiCalc(Wm(1,curr_m), J(curr_m), B(curr_m), I(curr_m), I(curr_m+1));
                if ~validWm
                    return
                end
    
                startRow = firstFree_mem(1,curr_m);
    
                %Memorize calculated Psi 
                for i = 0:(size(psi{curr_m},1)-1)
                    %Allocate more memory if necessary
                    if size(mem{curr_m},1) < startRow + size(psi{curr_m},1)
                        memExpansion = max(size(psi{curr_m},1), 1e6); %Arbitrary
                        mem{curr_m} = [mem{curr_m}; false(memExpansion, I(curr_m+1)-I(curr_m))];
                        bk_mem{curr_m} = [bk_mem{curr_m}; inf(memExpansion, 1, 'single')];
                    end
                    
                    %Memorize
                    mem{curr_m}(startRow + i,:) = psi{curr_m}(i+1,:);
                    bk_mem{curr_m}(startRow + i,1) = Wm(1,curr_m);
                    firstFree_mem(1,curr_m) = firstFree_mem(1,curr_m) + 1;
                end
            else
                %Retrieve Psi from memory
                psi{curr_m} = mem{curr_m}(psi_rows,:);
            end
    
        end
    end
end
    


function [Psi, validWm] = psiCalc(Wi, Ji, Bi, Ii, Iii)
    Psi = 0;
    
    %Returns set H_Wi of all possible Hamming weights for Wi
    [H_Wi, validWm] = validHamm(Wi, Ji, Bi, Ii, Iii);

    if ~validWm
        return
    end

    subSeqSize = Iii - Ii;

    PsiSize = 1e4; %Arbitrary size
    Psi = false(PsiSize,subSeqSize);

    %Loop through all Hamming weights wi in H_Wi
    psi_row = 0;
    for wi_i = 1:size(H_Wi)
        wi = H_Wi(wi_i);

        %subSeqs is a matrix with each row a possible sub-sequence
        if wi ~= 0
            [subSeqs] = subSeqGen(Wi, wi, subSeqSize, Ji, Bi);
        else
            subSeqs = false(1,subSeqSize);
        end

        %Expand an arbitrary amount (10000)
        if (psi_row + size(subSeqs,1) > PsiSize)
            PsiSize = PsiSize + size(subSeqs,1) + 1e4;
            Psi = [Psi; false(size(subSeqs,1)+1e4,subSeqSize)];
        end

        %Add subsequence to psi
        for subSeq_row = 1:size(subSeqs,1)
            psi_row = psi_row + 1;
            Psi(psi_row,:) = subSeqs(subSeq_row,:); 
        end
    end

    %Delete unused rows
    Psi = Psi(1:psi_row,:);
end

















