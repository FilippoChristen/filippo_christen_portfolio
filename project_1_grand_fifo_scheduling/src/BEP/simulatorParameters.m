% =========================================================================
% File        : simulatorParameters.m
% -------------------------------------------------------------------------
% Parameters for throughput simulation.
%
% [1] C. Ji, X. You, C. Zhang, and C. Studer, “Efficient ORBGRAND
% implementation with parallel noise sequence generation,” IEEE Trans.
% VLSI Syst., pp. 1–14, 2024.
% =========================================================================


function pars = simulatorParameters()
    %Simulation parameters
    pars.simName = "sim";
    pars.savePath = "data";

    pars.dataName = "inputData.mat";
    pars.dataPath = "data"; 

    pars.cwNum = 1e3; %Codewords to pass through the simulator % CHANGE
    pars.maxClk = 1e12; %Maximum clock cycles (avoiding infinite runtime)

    %Simulation range
    pars.ebn = [2:1:7];
    pars.decNum = [1,2]; %[1,2,4,8,16]; 
    pars.fifoSize = [0,1,2];%[0,1,2,4,8,16]; 
    pars.inRate = [1,4,16,64]; %[1,4,16,64,256,1024,4096,16384,65536,262144];
    pars.reoSize = [1,2];  
    pars.outRate = 0.9; %outRate/inRate ratio

    pars.decTrialsPerIts = 4; % Note: This is not a constant in [1] [noise sequences / cycle]
    pars.decMaxIts = 1e3; % Will kill decoder even if FIFO not full. 

    %Save results
    pars.collectResultsAfter = 100; %After how many cw the results should start being collected

    pars.progressUpdate = 1e9; %After how many outputs to report progress
    pars.debugMode = false;
end




