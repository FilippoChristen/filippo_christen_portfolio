% =========================================================================
% File        : inputDataGenerator.m
% -------------------------------------------------------------------------
% Simulation of codeword transmission over noisy channel and subsequent
% decoding.
%
% Bitstrings are randomly generated and encoded according to an arbitrary
% error correction code. The transmission of the resulting codewords over a
% noisy AWGN, BPSK channel is then simulated. After the simulated
% transmission, the bitstrings "bithat" are decoded by ORBGRAND, and
% finally checked against the originally sent bitstring, to assess decoding
% accuracy. 
% Each decoding is associated to a unique ID. The required iterations for
% the decoding, the decoding correctness, and a flag indicating if the
% decoding was abandoned are all saved as a struct, to be subsequently
% given to the FIFO Scheduling simulation. This strategy mitigates 
% redundant decoding effort in the simulation.
% =========================================================================

function inputDataGenerator()
    pars = inputDataGeneratorParameters;
    rng(pars.rng, 'twister');

    fprintf("============= GENERATING INPUT DATA ============= \n");
    fprintf("decodings: %d, maximum iterations: %d\n", pars.codewordNum, pars.decoder.max_iters);

    inputData = struct("ebn", struct("cw", struct("id", 0, "reqIts", 0, "corrDec", 0, "abandoned", 0)));
    for ebnIdx = 1:size(pars.ebn,2)
        currEbn = pars.ebn(1,ebnIdx);
    
        %Convert Eb/N0 to SNR
        snr = currEbn + 10*log10(pars.decoder.k/pars.decoder.n) + 10*log10(2);
    
        fprintf("----- Eb/N0 = %.1f -----\n", currEbn);

        for cwIdx = 1:pars.codewordNum
            %Progress update
            if mod(cwIdx,pars.progressUpdate) == 0
                prog = (cwIdx / pars.codewordNum) * 100;
                fprintf("progress: %.2f %%\n", prog);
            end
    
            %Channel simulation
            bits     = randi([0,1], 1, pars.decoder.k);
            sigma2   = 10^(-snr/10);
            encoded_bits = encoder(bits, pars.decoder.G);
            mapped_bits  = 1 - 2*encoded_bits;
            n = sqrt(sigma2)*randn(1, length(encoded_bits));
            y = mapped_bits + n;
            llrs   =  2*y/sigma2;
            
            %Calling decoder
            [bithat, success, reqIts] = ORBGRAND(pars.decoder, llrs);
           
            %Check if decoding correct
            correctDecoding = true;
            diffs = sum(bithat ~= bits);
            if diffs ~= 0
                correctDecoding = false;
            end

            %Store data
            inputData.ebn(ebnIdx).cw(cwIdx).id = uint32(cwIdx);
            inputData.ebn(ebnIdx).cw(cwIdx).reqIts = uint32(reqIts);
            inputData.ebn(ebnIdx).cw(cwIdx).corrDec = logical(correctDecoding);
            inputData.ebn(ebnIdx).cw(cwIdx).abandoned = logical(~success);
        end
    end

    %Save the data
    inputDataPars = pars;
    save(fullfile(pars.saveDir, pars.fileName), "inputData", "inputDataPars");
    fprintf("\n");
    fprintf("Data saved to: %s\n", fullfile(pars.saveDir, pars.fileName));
    fprintf("==================== FINISH ===================== \n");
end
