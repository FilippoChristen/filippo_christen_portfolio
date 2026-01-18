% =========================================================================
% File        : inputDataGeneratorParameters.m
% -------------------------------------------------------------------------
% Parameters for input data generation.
% =========================================================================


function config = inputDataGeneratorParameters()
    config.fileName = "inputData";

    config.saveDir = "data";
    codesDir = "codes/RLC256_234.mat";
    
    config.extraCw = 200; %Ensure capacity operation in FIFO Scheduling
    config.codewordNum = 1e3 + config.extraCw; %For each ebn
    config.ebn = [2:1:7];
    config.progressUpdate = 100; %How many codewords between progress updates

    config.decoder.type = "ORBGRAND";
    config.decoder.max_iters = 1e3 + 100;

    config.decoder.m = 4; %Number of segments
    config.decoder.mode = "limGeometric"; %Anchoring

    %RLC[256,234]
    G = load(codesDir).G;
    H = load(codesDir).H;
    config.decoder.G = logical(G);
    config.decoder.H = logical(H);

    [config.decoder.k, config.decoder.n] = size(config.decoder.G);

    %Constants (DON'T CHANGE)
    config.rng = 1000;
end


