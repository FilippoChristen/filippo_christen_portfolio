% =========================================================================
% Title       : Landslide algorithm
% File        : landslide.m
% -------------------------------------------------------------------------
% Generates all possible integer divisions of size n of integer tot,
% with w divisions. Calls build-mountain routine.
% Build-mountain routine adapted from [1] and [2].
%
% [1] https://github.com/kenrduffy/GRAND-MATLAB
% [2] K. R. Duffy, W. An, and M. Médard, “Ordered reliability bits guessing
% random additive noise decoding,” IEEE Trans. Signal Process., vol. 70,
% pp. 4528–4542, 2022.
% =========================================================================


function [U] = landslide(tot, w, n)
    max_rows = 5000; %Arbitrary size
    U = zeros(max_rows,w); 
    
    %Build mountain for initial partition
    u = 0; %Dummy input for first iteration
    k = 1;
    j = 1;
    u = buildMountain(u, tot, w, n, k);
    U(j,:) = u;
    
    %Iterate through the rest.
    D = getD(U(j,:));
    while D(1,1) >= 2
        %Update D
        for a = 1:(size(D,2)-1)
            if D(1,a) >= 2
                k = a;
            end
        end

        u(1,k) = u(1,k) + 1;
        u = buildMountain(u,tot,w,n,k);
        
        j = j+1;

        %Expand by an arbitrary amount
        if j > max_rows
            U = [U; zeros(5000,w)]; 
            max_rows = max_rows + 5000;
        end

        U(j,:) = u;
        D = getD(u);
    end

    %Remove unused rows
    U = U(1:j,:);
end



function [u] = buildMountain(u, W, w, n, k)
    u(1,k+1:w) = u(1,k)*ones(1,w-k);

    %Remainder to be built into a mountain
    W2 = W-sum(u);

    %Avoid division by zero
    q = 0;
    if W2 ~= 0
        q = floor(W2/(n-u(1,k)));
    end

    r = W2-q*(n-u(1,k));

    if q ~= 0
        u(1,(w-q+1):w)=n*ones(1,q);
    end
    if w-q>0
    	u(1,w-q)=u(1,w-q)+r;
    end
end



function [D] = getD(u)
    d = zeros(1,size(u,2));

    %Find d-vector
    for i = 1:(size(u,2)-1) %last entry always zero
        d(i) = u(i+1)-u(i);
    end
    D = cumsum(d,'reverse');
end








