% =========================================================================
% File        : simulator.m
% -------------------------------------------------------------------------
% First-In First-Out (FIFO) Scheduling simulation.
%
% Saved input data is fed to the FIFO Scheduling simulator and performance 
% statistics are analysed and saved.
%
% Each clock cycle the following can happen:
% - Re-ordering buffer pops
% - New input data is given to the system
% - FIFO pops and booking mechanism is executed
% - Decoder is pushed
% - FIFO is pushed
% - Early termination is issued
% - Decoders are iterated
% - Early termination is executed and corresponding decoder flushed
% - Output data is collected
% - Decoder pops
% =========================================================================

function simulator()
    pars = simulatorParameters;

    %Load input data
    inputData = load(fullfile(pars.dataPath, pars.dataName)).inputData;
    inputDataPars = load(fullfile(pars.dataPath, pars.dataName)).inputDataPars;

    %Checks if input data is valid with selected simulation parameters
    checkCompatibility(pars, inputDataPars)

    fprintf("============= SIMULATING ============= \n");
    fprintf("decodings: %d, maximum iterations: %d\n", pars.cwNum, pars.decMaxIts);

    %Initialize statistics tensors
    %min dim = 2, to avoid singleton dimension collapse
    ebnDim = max(size(pars.ebn,2),2);
    inRateDim = max(size(pars.inRate,2),2);
    decNumDim = max(size(pars.decNum,2),2);
    fifoSizeDim = max(size(pars.fifoSize,2),2);
    reoSizeDim = max(size(pars.reoSize,2),2);
    
    corrDecs = zeros(ebnDim, inRateDim, decNumDim, fifoSizeDim, reoSizeDim, 'uint32');
    forcedTerms = zeros(ebnDim, inRateDim, decNumDim, fifoSizeDim, reoSizeDim, 'uint32');
    maxLatency = zeros(ebnDim, inRateDim, decNumDim, fifoSizeDim, reoSizeDim, 'uint32');
    activeCycles = zeros(ebnDim, inRateDim, decNumDim, fifoSizeDim, reoSizeDim, 'uint64');
    elapsedClockCycles = zeros(ebnDim, inRateDim, decNumDim, fifoSizeDim, reoSizeDim, 'uint64');
    valid = false(ebnDim, inRateDim, decNumDim, fifoSizeDim, reoSizeDim);

    for ebnIdx = 1:size(pars.ebn,2)
        ebn = pars.ebn(1,ebnIdx);

        fprintf("--------------- Eb/N0 = %.1f [dB] ---------------\n", ebn);
        currInputData = inputData.ebn(ebnIdx);
        inputDataSize = size(currInputData.cw(:),1);

        for inRateIdx = 1:size(pars.inRate,2)
            inRate = pars.inRate(1,inRateIdx);

            %Compute output rate
            if inRate == 1
                outRate = inRate;
            else
                outRate = floor(pars.outRate*inRate);
            end

            for decNumIdx = 1:size(pars.decNum,2)
                decNum = pars.decNum(1,decNumIdx);
                for fifoSizeIdx = 1:size(pars.fifoSize,2)
                    fifoSize = pars.fifoSize(1,fifoSizeIdx);
                    for reoSizeIdx = 1:size(pars.reoSize,2)
                        reoSize = pars.reoSize(1,reoSizeIdx);

                        %Filter parametrizations
                        if reoSize < decNum
                            continue;
                        end

                        valid(inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx) = true;

                        fprintf("I = %d, F = %d, D = %d, R = %d O = %d\n", inRate, fifoSize, decNum, reoSize, outRate);
                        
                        inputDataNext = 1; %Next codeword idx
                        decReady = true;
                        outputData = repmat(struct('id', 0, 'reqIts', 0, 'corrDec', 0, 'abandoned', 0,'latency', 0), pars.cwNum,1);
                        outputDataNext = 1;
                        decTerminate = false;
                        activeDec = 0;
                        elapsedClk = 0;

                        %Only collect results once system starts working normally
                        % --> once 100 inputs have been released into the
                        %     system
                        collectResults = false;

                        [fifo, dec, reo, outBuffer] = init(fifoSize, decNum, reoSize);

                        %Main loop
                        for clk = 0:(pars.maxClk-1) 
                            if pars.debugMode
                                fprintf("---clk: %d---\n", clk);
                                printMemContents(fifo, dec, reo, outBuffer, fifoSize, decNum, reoSize);
                            end
                        
                            %Pop reo
                            [reoOut, reoOutReady, reo, outBuffer] = iterateReo(reo, clk, outRate, reoSize, outBuffer);

                            %Collect output
                            if collectResults && reoOutReady
                                outputData(outputDataNext) = reoOut;
                                outputDataNext = outputDataNext + 1;
                           
                                %Stop if codeword goal reached
                                if outputDataNext-1 == pars.cwNum
                                    break
                                end
                            end

                            if pars.debugMode
                                fprintf("pop re-ordering buffer\n");
                                printMemContents(fifo, dec, reo, outBuffer, fifoSize, decNum, reoSize);
                            end

                            %Input new data
                            [cw1, cw1Ready, inputDataNext, finished, collectResults] = release(currInputData, inputDataNext, clk, pars, inRate, collectResults, inputDataSize);
                            if finished %Stop if codewords finished
                                error("Input data finished before simulation end.");
                            end 

                            if collectResults && elapsedClk == 0
                                elapsedClk = clk;
                            end

                            %Pop fifo & Booking
                            [cw2, cw2Ready, fifo, reo] = popFifo(cw1, cw1Ready, decReady, fifo, reo, fifoSize, reoSize);

                            %Push decoder
                            [decReady, dec] = pushDec(cw2, cw2Ready, dec, decNum);

                            if pars.debugMode
                                fprintf("pop FIFO and push decoder\n");
                                printMemContents(fifo, dec, reo, outBuffer, fifoSize, decNum, reoSize);
                            end

                            %Push fifo
                            [fifo] = pushFifo(cw1, cw1Ready, fifo, fifoSize);

                            if pars.debugMode
                                fprintf("input new data and push FIFO\n");
                                printMemContents(fifo, dec, reo, outBuffer, fifoSize, decNum, reoSize);
                            end

                            %Issue early Termination
                            [decTerminate, fifo] = issueEarlyTermination(decTerminate, decReady, fifo, reo, clk, fifoSize, reoSize, inRate); 

                            if pars.debugMode && decTerminate
                                fprintf("EARLY TERMINATION ISSUED\n");
                            end

                            %Iterate decoder & Early Termination + flushing
                            [decTerminate, dec, reo, activeDec, decOrdering, flushedOutput, flushedOutputReady] = iterateDec(dec, reo, decTerminate, pars, decNum, reoSize, collectResults, activeDec, clk);

                            if pars.debugMode
                                fprintf("iterate decoders, and early terminate\n");
                                printMemContents(fifo, dec, reo, outBuffer, fifoSize, decNum, reoSize);
                            end

                            %Collect early terminated and thus flushed data
                            if collectResults && flushedOutputReady
                                outputData(outputDataNext) = flushedOutput;
                                outputDataNext = outputDataNext + 1;
                           
                                %Stop if codeword goal reached
                                if outputDataNext-1 == pars.cwNum
                                    break
                                end

                                if mod(outputDataNext-1,pars.progressUpdate) == 0
                                    prog = ((outputDataNext-1) / pars.cwNum) * 100;
                                    fprintf("progress: %.2f %%\n", prog);
                                end 
                            end

                            %Pop decoder
                            [decReady, dec, reo] = popDec(dec, reo, decNum, reoSize, decOrdering);

                            if pars.debugMode
                                fprintf("pop decoder\n");
                                printMemContents(fifo, dec, reo, outBuffer, fifoSize, decNum, reoSize);
                            end
                        end

                        %Compute statistics
                        correctDecodings = 0;
                        forcedTermsNum = 0;
                        for i = 1:pars.cwNum
                            if outputData(i).corrDec
                                correctDecodings = correctDecodings + 1;
                            end

                            if outputData(i).abandoned
                                forcedTermsNum = forcedTermsNum + 1;
                            end
                        end

                        elapsedClk = clk - elapsedClk + 1;

                        corrDecs(ebnIdx, inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx) = correctDecodings;
                        forcedTerms(ebnIdx, inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx) = forcedTermsNum;
                        maxLatency(ebnIdx, inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx) = max([outputData.latency], [], "all");
                        activeCycles(ebnIdx, inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx) = activeDec;
                        elapsedClockCycles(ebnIdx, inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx) = elapsedClk;
                    end
                end
            end
        end
        fprintf("--------------- Finished Eb/N0 = %.1f [dB] ---------------\n", ebn);
    end

    %Save data
    fullFileName = fullfile(pars.savePath, pars.simName);
    simulationInfo = pars;
    inputDataInfo = inputDataPars;
    save(fullFileName, "simulationInfo", "inputDataInfo", "corrDecs","forcedTerms", "maxLatency", "activeCycles", "elapsedClockCycles", "valid");

    fprintf("\n");
    fprintf("Data saved to: %s\n", fullFileName);
    fprintf("\n================= FINISHED =================\n");
end


function checkCompatibility(pars, inputDataPars)
    if inputDataPars.decoder.max_iters < pars.decMaxIts
        %Explanation: iterating further in the simulation as done in the 
        %             precalculated data leads to incorrect BLER results.
        error("Simulation maximum iterations can't exceed precalculated data maximum iterations.");
    end

    if inputDataPars.codewordNum < pars.cwNum + pars.collectResultsAfter
        error("Not enough input codewords for the provided simulation parameters.");
    end

    for ebnIdx = 1:size(pars.ebn,2)
        %Explanation: simulator ebn range has to be subset of input data
        %             ebn range.
        ebn = pars.ebn(1,ebnIdx);
        if ~ismember(ebn,inputDataPars.ebn)
            error("Simulation ebn range incompatible with input data ebn range.\n ebn: %f not contained in input data.\n", ebn);
        end
    end
end


function [fifo, dec, reo, outBuffer] = init(fifoSize, decNum, reoSize)
    %Initializing fifo
    fifoSlot = struct('free', true, 'cw', struct('id', 0, 'reqIts', 0, 'corrDec', 0, 'abandoned', 0, 'latency', 0));
    fifo.slot = repmat(fifoSlot, 1, fifoSize);
    fifo.nextFree = 1;

    %Initializinig decoders
    singleDec = struct('free', true, 'idle', false, 'doneIts', 0, 'cw', struct('id', 0, 'reqIts', 0, 'corrDec', 0, 'abandoned', 0, 'latency', 0)); 
    dec = repmat(singleDec, 1, decNum);
    
    %Initializing re-ordering buffer
    reoSlot = struct('free', true, 'booking', 0, 'cw', struct('id', 0, 'reqIts', 0, 'corrDec', 0, 'abandoned', 0, 'latency', 0));
    reo.slot = repmat(reoSlot, 1, reoSize);
    reo.nextFree = 1;

    %Initializing the output buffer
    outBuffer = struct('id', 0, 'reqIts', 0, 'corrDec', 0, 'abandoned', 0, 'latency', 0);
end


function [cw1, cw1Aval, inputDataNext, finished, collectResults] = release(inputData, inputDataNext, clk, pars, inRate, collectResults, inputDataSize)
    cw1 = 0;
    cw1Aval = false;
    finished = false;
    if mod(clk, inRate) == 0
        %Check if input data finished
        if inputDataNext <= inputDataSize
            cw1 = inputData.cw(inputDataNext);
            cw1.latency = clk;
            cw1Aval = true;

            if inputDataNext == pars.collectResultsAfter + 1
                collectResults = true;
            end

            inputDataNext = inputDataNext + 1;
        else
            finished = true;
            return
        end
    end
end


function [cw2, cw2Ready, fifo, reo] = popFifo(cw1, cw1Ready, decReady, fifo, reo, fifoSize, reoSize)
    cw2 = 0;
    cw2Ready = false;

    %If no FIFO
    if fifoSize == 0
        cw2 = cw1;
        cw2Ready = cw1Ready;
        
        if cw2Ready
            reo.slot(reo.nextFree).booking = cw2.id;
            reo.nextFree = reo.nextFree + 1;
        end
        return;
    end

    %Pop fifo
    if reo.nextFree <= reoSize
        if decReady && fifo.nextFree > 1
            cw2 = fifo.slot(1).cw;
            cw2Ready = true;

            %Booking mechanism
            reo.slot(reo.nextFree).booking = cw2.id;
            reo.nextFree = reo.nextFree + 1;

            %Shift all full fifo elements to the front
            for i = 2:fifoSize
                fifo.slot(i-1).cw = fifo.slot(i).cw;
            end
            %Reset last slot
            fifo.slot(end).cw.id = 0;
            fifo.slot(end).cw.reqIts = 0;
            fifo.slot(end).cw.corrDec = false;
            fifo.slot(end).cw.abandoned = false;
            fifo.slot(end).cw.latency = 0;

            fifo.nextFree = fifo.nextFree - 1;
        end
    end
end


function [fifo] = pushFifo(cw1, cw1Ready, fifo, fifoSize)
    if fifoSize == 0
        return;
    end

    %Push fifo
    if cw1Ready
        %Check if fifo full
        if fifo.nextFree <= fifoSize
            fifo.slot(fifo.nextFree).cw = cw1;
            fifo.nextFree = fifo.nextFree + 1;
        else
            error("Fifo full, dataloss happened");
        end
    end
end


function [decTerminate, fifo] = issueEarlyTermination(decTerminate, decReady, fifo, reo, clk, fifoSize, reoSize, inRate)
    if mod(clk+1, inRate) == 0
        %Check if there will be a re-ordering buffer slot available in time
        reoSlotAvail = ~(reo.nextFree > reoSize) || reo.slot(1).cw.id == reo.slot(1).booking;

        if (fifoSize == 0 || fifo.nextFree > fifoSize) && (~decReady || ~reoSlotAvail)
            decTerminate = true;
        end
    end
end


function [decReady, dec, reo] = popDec(dec, reo, decNum, reoSize, decOrdering)
    %Collect as soon as decoder finishes
    for i = 1:decNum
        if dec(decOrdering(i)).idle
            %Unload one cw from decoder to booked slot
            for j = 1:reoSize
                if dec(decOrdering(i)).cw.id == reo.slot(j).booking
                    reo.slot(j).cw = dec(decOrdering(i)).cw;
                    reo.slot(j).free = false;
                    break;
                end
            end

            %Reset decoder
            dec(decOrdering(i)).free = true;
            dec(decOrdering(i)).idle = false;
            dec(decOrdering(i)).doneIts = 0;
            dec(decOrdering(i)).cw.id = 0;
            dec(decOrdering(i)).cw.reqIts = 0;
            dec(decOrdering(i)).cw.corrDec = false;
            dec(decOrdering(i)).cw.abandoned = false;
            dec(decOrdering(i)).cw.latency = 0;

            %Can only collect one cw per iteration
            break;
        end
    end

    %Check if there are any free decoders left
    decReady = false; %True if at least one decoder is free
    for i = 1:decNum
        if dec(i).free
            decReady = true;
            %One free decoder is enough
            break;
        end
    end
end


function [decReady, dec] = pushDec(cw2, cw2Ready, dec, decNum)
    %Distribute as soon as cw popped from fifo
    if cw2Ready
        %Find free decoder (this is ensured by decReady)
        for i = 1:decNum
            if dec(i).free
                dec(i).cw = cw2;
                dec(i).free = false;
                
                %Can only distribute one cw per iteration
                break;
            end
        end
    end

    %Check if there are any free decoders left
    decReady = false; %True if at least one decoder is free
    for i = 1:decNum
        if dec(i).free
            decReady = true;
            %One free decoder is enough
            break;
        end
    end
end


function [decTerminate, dec, reo, activeDec, decOrdering, flushedOutput, flushedOutputReady] = iterateDec(dec, reo, decTerminate, pars, decNum, reoSize, collectResults, activeDec, clk)
    flushedOutput = 0;
    flushedOutputReady = false;

    %Iterate decoder
    for i = 1:decNum
        if ~dec(i).free
            %Note: Iterate even if idling, to maintain decoder sorting order
            dec(i).doneIts = dec(i).doneIts + pars.decTrialsPerIts;

            if ~dec(i).idle
                if collectResults
                    activeDec = activeDec + 1;
                end
    
                %Set decoder to idle if finished
                if (dec(i).doneIts >= dec(i).cw.reqIts)
                    dec(i).idle = true;
                end
            end
        end
    end

    %Sort decoders by done iterations
    [~, decOrdering] = sort([dec.doneIts], 'descend');
    
    %Early termination of longest running decoder
    for i = 1:decNum
        if (dec(i).doneIts >= pars.decMaxIts) || (decTerminate && i == decOrdering(1))
            %NOTE: Sometimes decoder is freed before it gets forcefully
            %terminated (it if finishes iterating at the same clk
            %cycle).

            if ~dec(i).idle && ~dec(i).free
                %Decoding is unsuccessful
                dec(i).cw.corrDec = false;
                dec(i).cw.abandoned = true;
                dec(i).idle = true;

                %Flush decoder
                flushedOutput = dec(i).cw;
                flushedOutputReady = true;
                flushedOutput.latency = clk - flushedOutput.latency;

                %Reset decoder
                dec(i).free = true;
                dec(i).idle = false;
                dec(i).doneIts = 0;
                dec(i).cw.id = 0;
                dec(i).cw.reqIts = 0;
                dec(i).cw.corrDec = false;
                dec(i).cw.abandoned = false;
                dec(i).cw.latency = 0;

                %Sort decoders by done iterations
                [~, decOrdering] = sort([dec.doneIts], 'descend');

                %Flush reo slot and push slots appropriately --> TODO: make
                %more efficient
                for j = 1:reoSize             
                    if flushedOutput.id == reo.slot(j).booking
                        %Flush reo slot
                        reo.slot(j).cw.id = 0;
                        reo.slot(j).cw.reqIts = 0;
                        reo.slot(j).cw.corrDec = false;
                        reo.slot(j).cw.abandoned = false;
                        reo.slot(j).cw.latency = 0;
                        reo.slot(j).booking = 0;
                        reo.slot(j).free = true;

                        if j ~= reoSize
                            if reo.nextFree > reoSize
                                for a = j+1:reoSize
                                    reo.slot(a-1) = reo.slot(a);
                                end
                                
                                %Reset last entry
                                reo.slot(end).free = true;
                                reo.slot(end).booking = 0;
                                reo.slot(end).cw.id = 0;
                                reo.slot(end).cw.reqIts = 0;
                                reo.slot(end).cw.corrDec = false;
                                reo.slot(end).cw.abandoned = false;
                                reo.slot(end).cw.latency = 0;
                            else
                                for a = j+1:reo.nextFree
                                    reo.slot(a-1) = reo.slot(a);
                                end
                            end
                        end
                    reo.nextFree = reo.nextFree - 1;
                    break;
                    end
                end
            end

            decTerminate = false;
            break;
        end
    end
end


function [reoOut, reoOutReady, reo, outBuffer] = iterateReo(reo, clk, outRate, reoSize, outBuffer)
    reoOut = 0;
    reoOutReady = false;

    %Insert decoding into output buffer as soon as possible
    if  ~reo.slot(1).free && outBuffer.id == 0
        outBuffer = reo.slot(1).cw;

        %Reset slot
        reo.slot(1).cw.id = 0;
        reo.slot(1).cw.reqIts = 0;
        reo.slot(1).cw.corrDec = false;
        reo.slot(1).cw.abandoned = false;
        reo.slot(1).cw.latency = 0;
        reo.slot(1).booking = 0;
        reo.slot(1).free = true;

        %Shift all booked slots to the front
        if reoSize > 1
            if reo.nextFree > reoSize
                for i = 2:reoSize
                    reo.slot(i-1) = reo.slot(i);
                end
            else
                for i = 2:reo.nextFree
                    reo.slot(i-1) = reo.slot(i);
                end
            end
 
            %Reset last entry
            reo.slot(end).free = true;
            reo.slot(end).booking = 0;
            reo.slot(end).cw.id = 0;
            reo.slot(end).cw.reqIts = 0;
            reo.slot(end).cw.corrDec = false;
            reo.slot(end).cw.abandoned = false;
            reo.slot(end).cw.latency = 0;
        end

        reo.nextFree = reo.nextFree - 1;
    end


    %Release decoding from output buffer at outRate
    if mod(clk, outRate) == 0 && outBuffer.id ~= 0
        reoOut = outBuffer;
        reoOut.latency = clk - reoOut.latency;
        reoOutReady = true;

        %Reset slot
        outBuffer.id = 0;
        outBuffer.reqIts = 0;
        outBuffer.corrDec = false;
        outBuffer.abandoned = false;
        outBuffer.latency = 0;
    end
end




%Prints cw stored in fifo, decoder, re-ordering buffer and output buffer
function printMemContents(fifo, dec, reo, outBuffer, fifoSize, decNum, reoSize)
    fprintf("FIFO\n");
    outString = '|';
    for a = 1:fifoSize
        outString = [outString, num2str(fifo.slot(a).cw.id), '|'];
    end
    fprintf("%s\n", outString);

    fprintf("DECODERS\n");
    outString = '|';
    for a = 1:decNum
        outString = [outString, num2str(dec(a).cw.id), '|'];
    end
    fprintf("%s\n", outString);

    fprintf("RE-ORDERING BUFFER CONTENTS\n");
    outString = '|';
    for a = 1:reoSize
        outString = [outString, num2str(reo.slot(a).cw.id), '|'];
    end
    fprintf("%s\n", outString);

    fprintf("RE-ORDERING BUFFER BOOKINGS\n");
    outString = '|';
    for a = 1:reoSize
        outString = [outString, num2str(reo.slot(a).booking), '|'];
    end
    fprintf("%s\n", outString);

    fprintf("OUTPUT BUFFER\n");
    fprintf("|%d|\n", outBuffer.id);
end


