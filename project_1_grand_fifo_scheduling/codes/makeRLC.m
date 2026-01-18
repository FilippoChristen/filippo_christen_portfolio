% =========================================================================
% Title       : Make random linear code
% File        : makeRLC.m
% -------------------------------------------------------------------------
% Generates linear code matrices G and H. 
% Code taken from: https://github.com/kenrduffy/GRAND-MATLAB.git
% -------------------------------------------------------------------------
% K. R. Duffy, J. Li, and M. Medard, 
% "Capacity-achieving guessing random  additive noise decoding," 
% IEEE Trans. Inf. Theory, vol. 65, no. 7, pp. 4023–4040, 2019.

% A. Riaz, V. Bansal, A. Solomon, W. An, Q. Liu, K. Galligan, K. R. Duffy, 
% M. Medard and R. T. Yazicigil, 
% "Multi-code multi-rate universal maximum likelihood decoder using GRAND,"
% Proceedings of IEEE ESSCIRC, 2021.

% K. R. Duffy, 
% "Ordered reliability bits guessing random additive noise decoding," 
% Proceedings of IEEE ICASSP, 2021, pp. 8268–8272.

% K. R. Duffy, W. An, and M. Medard, 
% "Ordered reliability bits guessing random additive noise decoding," 
% IEEE Trans. Signal Process., vol. 70, pp. 4528-4542, 2022.
% =========================================================================


function [G,H] = makeRLC(k,n,p)
    rng(1000, 'twister');
    P = make_parity_check(k,n,p);
    % If there are duplicate rows, re-randomise
    while (size(unique(P','rows'),1)<n-k)
        P = make_parity_check(k,n,p);
    end
    G = [eye(k) P];
    H = [transpose(P) eye(n-k)];

end

function P = make_parity_check(k,n,p)
    P = binornd(1,p,k,n-k); 
    % If a row is all zeros, then the associated bit has no protection so
    % pick again.
    tf=ismember(P,zeros(1,n-k),'rows');
    while (sum(tf)>0)
        tf=ismember(P,zeros(1,n-k),'rows');
        P(tf,:) = binornd(1,p,sum(tf),n-k);
    end
end