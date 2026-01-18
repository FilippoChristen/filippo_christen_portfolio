% =========================================================================
% File        : encoder.m
% -------------------------------------------------------------------------

function [encoded_bits] = encoder(inf_bits, G)
    %encoding
    encoded_bits = mod(inf_bits * G,2);
end
