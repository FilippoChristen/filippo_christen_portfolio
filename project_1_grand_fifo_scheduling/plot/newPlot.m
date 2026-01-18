% =========================================================================
% File        : newPlot.m
% -------------------------------------------------------------------------
% Script used to produce relevant plots.
% =========================================================================

% Parameters
dataName = "fifoSchedData1.mat";
dataPath = "/usr/scratch/steenodde/fchrist/condor/fifoSched/united";

BLER = 0.01; %Should do for 0.01

losses = [0,0.1,0.2,0.3];

decOperatingFreq = 746e6; %[Hz] [1]

dffArea = 8e-6; %[mm2]
decArea = 0.97; %[mm2] [1]

bitPerLLR = 5; %[bits] [1]

energyPerBit = 2.11e-12; %[J/bit] [1] --> avg., not used here
averagePower = 86.1; %[mW] [1]


%==========================================================================

%Load data
simulationInfo = load(fullfile(dataPath,dataName)).simulationInfo;
inputDataInfo = load(fullfile(dataPath,dataName)).inputDataInfo;

corrDecs = load(fullfile(dataPath,dataName)).corrDecs;
forcedTerms = load(fullfile(dataPath,dataName)).forcedTerms;
maxLatency = load(fullfile(dataPath,dataName)).maxLatency;
totalIterations = load(fullfile(dataPath,dataName)).totalIterations;
activeCycles = totalIterations; %TODO change when you have data
elapsedClockCycles = load(fullfile(dataPath,dataName)).elapsedClockCycles;
valid = load(fullfile(dataPath,dataName)).valid;

inputData = load(fullfile(simulationInfo.dataPath, simulationInfo.dataName)).inputData;
%BLER vs Eb/N0 plots --> Suppose same ebn range for input data and
%simulation data. TODO: make compatible for different ranges if necessary

%Reference
refBler = zeros(size(simulationInfo.ebn), "double");
refReqIts = zeros(size(simulationInfo.ebn), "double");
for ebnIdx = 1:size(refBler,2)
    refBler(1,ebnIdx) = 1 - mean([inputData.ebn(ebnIdx).cw.corrDec]);
    refReqIts(1,ebnIdx) = mean([inputData.ebn(ebnIdx).cw.reqIts]);
end


%Calculate BLER and dynamic power of all valid parametrizations
detBler = zeros(size(simulationInfo.ebn,2), size(simulationInfo.inRate,2), size(simulationInfo.decNum,2), size(simulationInfo.fifoSize,2), size(simulationInfo.reoSize,2), "double");
dynamicPower = zeros(size(simulationInfo.ebn,2), size(simulationInfo.inRate,2), size(simulationInfo.decNum,2), size(simulationInfo.fifoSize,2), size(simulationInfo.reoSize,2), "double");
for inRateIdx = 1:size(simulationInfo.inRate,2)
    for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
        for decNumIdx = 1:size(simulationInfo.decNum,2)
            for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
                if ~valid(1, inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx)
                    continue;
                end

                detBler(:,inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx) = 1 - double(corrDecs(:,inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx)) ./ double(simulationInfo.cwNum);

                dynamicPower(:,inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx) = averagePower*double(activeCycles(:,inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx)) ./ double(elapsedClockCycles(:,inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx));
            end
        end
    end
end

%Plot BLER vs Eb/N0 curves
plotBLERvsEBN0curves = true;
if plotBLERvsEBN0curves
    figure
    hold on
    grid on
    set(gca, 'YScale', 'log');
    title("BLER vs Eb/N0 for different parametrizations");
    xlabel("Eb/N0 [dB]");
    ylabel("BLER");
    plot(simulationInfo.ebn,refBler, "-x", "LineWidth", 2, "Color", "b");

    for inRateIdx = 1:size(simulationInfo.inRate,2)
        for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
            for decNumIdx = 1:size(simulationInfo.decNum,2)
                for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
                    inRate = simulationInfo.inRate(1,inRateIdx);
                    fifoSize = simulationInfo.fifoSize(1,fifoSizeIdx);
                    decNum = simulationInfo.decNum(1,decNumIdx);
                    reoSize = simulationInfo.reoSize(1,reoSizeIdx);
    
                    if ~valid(1,inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx)
                        continue;
                    end

                    plot(simulationInfo.ebn, detBler(:,inRateIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), "-x", "LineWidth", 2, "Color", "r");
                end
            end
        end
    end
    hold off;
end



%Interpolate reference values @ predetermined BLER
refEbN0_intPts = [0;0];
for ebnIdx = 1:size(simulationInfo.ebn,2)
    if refBler(1,ebnIdx) >= BLER && refBler(1,ebnIdx+1) < BLER
        refEbN0_intPts(1) = ebnIdx;
        refEbN0_intPts(2) = ebnIdx+1;
    end
end
refEbN0_int = interp1(log10(refBler(1,refEbN0_intPts)), simulationInfo.ebn(refEbN0_intPts), log10(BLER), 'linear');
refReqIts_int = interp1(log10(refBler(1,refEbN0_intPts)), refReqIts(refEbN0_intPts), log10(BLER), 'linear');


%Interpolate configuration values @ predetermined BLER
detEbN0_int = zeros(size(simulationInfo.inRate,2), size(simulationInfo.decNum,2), size(simulationInfo.fifoSize,2), size(simulationInfo.reoSize,2), "double");
for inRateIdx = 1:size(simulationInfo.inRate,2)
    for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
        for decNumIdx = 1:size(simulationInfo.decNum,2)
            for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
                if ~valid(1, inRateIdx, decNumIdx, fifoSizeIdx, reoSizeIdx)
                    continue;
                end

                detEbN0_intPts = [0;0];
                for ebnIdx = 1:size(simulationInfo.ebn,2)-1
                    if detBler(ebnIdx,inRateIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) >= BLER && detBler(ebnIdx+1,inRateIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) < BLER
                        detEbN0_intPts(1) = ebnIdx;
                        detEbN0_intPts(2) = ebnIdx + 1;
                        break;
                    end
                end

                %Case where no Eb/N0 allowed to reach the required BLER
                %with the give input rate.
                if detEbN0_intPts == [0;0]
                    detEbN0_int(inRateIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = 20; %Arbitrary choice
                else    
                    detEbN0_int(inRateIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = interp1(log10(detBler(detEbN0_intPts,inRateIdx,decNumIdx,fifoSizeIdx,reoSizeIdx)), simulationInfo.ebn(1,detEbN0_intPts), log10(BLER), 'linear');  
                end
            end
        end
    end
end


%Show the plot
figure
hold on
grid on
set(gca, 'YScale', 'log');
title("Throughput comparison for different parametrizations", sprintf("to get BLER = %.2f", BLER));
xlabel("Eb/N0 [dB]");
ylabel("TP");
plot(refEbN0_int,simulationInfo.decTrialsPerIts/double(refReqIts_int), "-x", "LineWidth", 3, "Color", "r");

simTP = 1 ./ double(simulationInfo.inRate);
for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
    for decNumIdx = 1:size(simulationInfo.decNum,2)
        for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
            if ~valid(1, 1, decNumIdx, fifoSizeIdx, reoSizeIdx)
                continue;
            end

            plot(detEbN0_int(:,decNumIdx,fifoSizeIdx,reoSizeIdx), simTP, "-x", "LineWidth", 2, "Color", "b");
        end
    end
end
hold off


%Throughput interpolation at different losses
detTPint = zeros(size(losses,2), size(simulationInfo.decNum,2), size(simulationInfo.fifoSize,2), size(simulationInfo.reoSize,2), "double");
latency = zeros(size(detTPint));
power = zeros(size(detTPint));
for lossIdx = 1:size(losses,2)
    loss = losses(1,lossIdx);
    for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
        for decNumIdx = 1:size(simulationInfo.decNum,2)
            for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
                if ~valid(1,1, decNumIdx, fifoSizeIdx, reoSizeIdx)
                    continue;
                end
    
                inRateintPts = [0;0];
                for ebnIdx_int = 1:size(simulationInfo.inRate,2)-1
                    if  detEbN0_int(ebnIdx_int,decNumIdx,fifoSizeIdx,reoSizeIdx) >= refEbN0_int + loss && detEbN0_int(ebnIdx_int+1,decNumIdx,fifoSizeIdx,reoSizeIdx) <= refEbN0_int + loss
                        inRateintPts(1) = ebnIdx_int;
                        inRateintPts(2) = ebnIdx_int+1;
                        break;
                    end
                end

                ebnPts = [0;0]; %This should always work in theory
                for ebnIdx = 1:size(simulationInfo.ebn,2)-1
                    if simulationInfo.ebn(1,ebnIdx) < refEbN0_int + loss && simulationInfo.ebn(1,ebnIdx+1) >= refEbN0_int + loss
                        ebnPts = [ebnIdx,ebnIdx+1];
                    end
                end

                if inRateintPts == [0;0]
                    detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = 1e-7; %Arbitrary
                    latency(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = 1e6;%Arbitrary
                    power(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = 1;%Arbitrary
                else
                    detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = interp1(detEbN0_int(inRateintPts,decNumIdx,fifoSizeIdx,reoSizeIdx), log10(simTP(1,inRateintPts)), refEbN0_int + loss, "linear");
                    latency(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = interp1(log10(simTP(1,inRateintPts)), double(maxLatency(inRateintPts,decNumIdx,fifoSizeIdx,reoSizeIdx)), detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), "linear");
                    power(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = interp2(log10(simTP(1,inRateintPts)), simulationInfo.ebn(1,ebnPts), dynamicPower(ebnPts, inRateintPts,decNumIdx,fifoSizeIdx,reoSizeIdx), detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), refEbN0_int + loss, "linear");
                    
                    detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx) = 10^detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx);
                end
            end
        end
    end
end


%Area
area = zeros(size(detTPint));
for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
    for decNumIdx = 1:size(simulationInfo.decNum,2)
        for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
            if ~valid(1, 1, decNumIdx, fifoSizeIdx, reoSizeIdx)
                continue;
            end

            fifoSize = simulationInfo.fifoSize(1,fifoSizeIdx);
            decNum = simulationInfo.decNum(1,decNumIdx);
            reoSize = simulationInfo.reoSize(1,reoSizeIdx);

            reoArea = reoSize*inputDataInfo.decoder.k*dffArea;
            fifoArea = fifoSize*inputDataInfo.decoder.n*bitPerLLR*dffArea;
            currArea = reoArea + fifoArea + decArea*decNum;
            area(decNumIdx,fifoSizeIdx,reoSizeIdx) = currArea;
        end
    end
end


%Plot tradeoffs
figure
hold on
grid on
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
xlabel("Throughput [bit/s]");
ylabel("Area [mm^2]");
title("Area vs Throughput at different Eb/N0 losses for BLER = 0.01"); 
colors = {'green','blue','yellow','red'};
for lossIdx = 1:size(losses,2)
    loss = losses(1,lossIdx);
    for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
        for decNumIdx = 1:size(simulationInfo.decNum,2)
            for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
                if ~valid(1, 1, decNumIdx, fifoSizeIdx, reoSizeIdx)
                    continue;
                end
    
                fifoSize = simulationInfo.fifoSize(1,fifoSizeIdx);
                decNum = simulationInfo.decNum(1,decNumIdx);
                reoSize = simulationInfo.reoSize(1,reoSizeIdx);
    
                scatter(detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), area(decNumIdx,fifoSizeIdx,reoSizeIdx), 'filled', 'MarkerFaceColor', colors{lossIdx});
                text(detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), area(decNumIdx,fifoSizeIdx,reoSizeIdx), sprintf('(f=%d,d=%d,r=%d)', fifoSize, decNum, reoSize), 'FontSize', 8);
            end
        end
    end
end
hold off


figure
hold on
grid on
set(gca, 'YScale', 'linear');
set(gca, 'XScale', 'log');
xlabel("Throughput [bit/s]");
ylabel("Power [mW]");
title("Power vs Throughput at different Eb/N0 losses for BLER = 0.01"); 
colors = {'green','blue','yellow','red'};
for lossIdx = 1:size(losses,2)
    loss = losses(1,lossIdx);
    for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
        for decNumIdx = 1:size(simulationInfo.decNum,2)
            for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
                if ~valid(1, 1, decNumIdx, fifoSizeIdx, reoSizeIdx)
                    continue;
                end
    
                fifoSize = simulationInfo.fifoSize(1,fifoSizeIdx);
                decNum = simulationInfo.decNum(1,decNumIdx);
                reoSize = simulationInfo.reoSize(1,reoSizeIdx);
    
                scatter(detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), power(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), 'filled', 'MarkerFaceColor', colors{lossIdx});
                text(detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), power(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), sprintf('(f=%d,d=%d,r=%d)', fifoSize, decNum, reoSize), 'FontSize', 8);
            end
        end
    end
end
hold off


figure
hold on
grid on
set(gca, 'YScale', 'linear');
set(gca, 'XScale', 'log');
xlabel("Throughput [bit/s]");
ylabel("Latency [s]");
title("Latency vs Throughput at different Eb/N0 losses for BLER = 0.01"); 
colors = {'green','blue','yellow','red'};
for lossIdx = 1:size(losses,2)
    loss = losses(1,lossIdx);
    for fifoSizeIdx = 1:size(simulationInfo.fifoSize,2)
        for decNumIdx = 1:size(simulationInfo.decNum,2)
            for reoSizeIdx = 1:size(simulationInfo.reoSize,2)
                if ~valid(1, 1, decNumIdx, fifoSizeIdx, reoSizeIdx)
                    continue;
                end
    
                fifoSize = simulationInfo.fifoSize(1,fifoSizeIdx);
                decNum = simulationInfo.decNum(1,decNumIdx);
                reoSize = simulationInfo.reoSize(1,reoSizeIdx);
    
                scatter(detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), latency(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), 'filled', 'MarkerFaceColor', colors{lossIdx});
                text(detTPint(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), latency(lossIdx,decNumIdx,fifoSizeIdx,reoSizeIdx), sprintf('(f=%d,d=%d,r=%d)', fifoSize, decNum, reoSize), 'FontSize', 8);
            end
        end
    end
end
hold off












