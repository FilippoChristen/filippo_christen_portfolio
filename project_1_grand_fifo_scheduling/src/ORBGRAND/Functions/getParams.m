% =========================================================================
% Title       : Segment approximation parameter generator
% File        : getParams.m
% -------------------------------------------------------------------------
% Calculates segment approximation parameters of reliablity-index curve of
% received log-likelyhood ratio values according to [1].
%
% [1] K. R. Duffy, W. An, and M. Médard, “Ordered reliability bits guessing
% random additive noise decoding,” IEEE Trans. Signal Process., vol. 70,
% pp. 4528–4542, 2022.
% =========================================================================


function [J, B, I] = getParams(config, L)
    m = config.m;
    n = config.n;
    mode = config.mode;
    
    %Get anchor points
    I = 0;
    switch mode
        case 'linear'
            I = anchorPts_linear(n,m);
        case 'geometric'
            I = anchorPts_geometric(n,m);
        case 'limGeometric'
            I = anchorPts_limGeometric(n,m);
        otherwise
            error("Invalid mode.");
    end

    %Parameters
    B = zeros(m,1); %slope of segment (i in {1,...,m})
    J = zeros(m,1); %initial value of segment (i in {0,...,m-1}). MATLAB index is one more than in paper.

    slopes = zeros(m,1);
    slopes(1) = (L(I(2))-L(1)) / (I(2)-1);
    for i = 2:m
        slopes(i) = (L(I(i+1))-L(I(i))) / (I(i+1)-I(i));
    end

    Q = min(slopes);

    for i = 1:m
        B(i) = floor(slopes(i)/Q);
    end

    J(1) = floor(L(1)/Q);
    for i = 2:m
        J(i) = floor(J(i-1) + B(i-1)*(I(i)-I(i-1)));
    end
end


%Anchor points regularly spaced based on m.
function [I] = anchorPts_linear(n,m) 
    I = zeros(m+1, 1);
    inc = floor(n/m);
    for i = 2:(m+1) 
        if i == m+1
            I(i) = n;
        else
            I(i) = I(i-1) + inc;
        end
    end
end


%Anchor points geometrically spaced.
function [I] = anchorPts_geometric(n,m)
    factor = 2; %Arbitrary choice

    %Avoid impossible spacing
    if floor(n/(factor^(m-1))) == 0
        %warning("m too large, using linear spacing.")
        I = anchorPts_linear(config, L);
        return;
    end

    I = zeros(m+1,1);
    I(1) = 0;
    I(m+1) = n;
    currdist = n;
    
    %Geometrically spaced anchor points
    for i = m:-1:2
        currdist = floor(currdist/factor);
        I(i) = currdist;
    end
end


%Anchor points geometrically spaced, but limited to minimum interval.
function [I] = anchorPts_limGeometric(n,m)
    %Arbitrary choices
    factor = 2;
    minDist = 8;

    %Avoid impossible spacing
    minLen = floor(n/(factor^(m-1)));
    if floor(n/minDist) < m
        %warning("m too large, using linear spacing.");
        I = anchorPts_linear(n,m);
        return;
    end

    %Check if normal geometric is enough
    if minLen >= minDist
        I = anchorPts_geometric(n,m);
        return;
    end

    %Add one minDist segment and check if more are necessary
    I = zeros(m+1,1);
    I(1) = 0;
    I(m+1) = n;
    currIdx = 1;
    while floor((n-I(currIdx))/(2^(m-currIdx))) < minDist
        currIdx = currIdx + 1;
        I(currIdx) = I(currIdx-1) + minDist;
    end
    
    %Geometrically spaced anchor points for the remaining part
    currdist = n-I(currIdx);
    for i = m:-1:currIdx+1
        currdist = floor(currdist/factor);
        I(i) = I(currIdx) + currdist;
    end
end





































