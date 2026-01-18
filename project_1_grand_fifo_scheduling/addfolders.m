% =========================================================================
% File        : addfolders.m
% -------------------------------------------------------------------------
% Adds all folders accessible by the root directory.
% Executing addfolders.m is necessary for other functions to be correctly
% run.
% =========================================================================

warning('off', 'MATLAB:rmpath:DirNotFound');

%Reset path
rmpath(genpath('./'));

%Add all paths
addpath(genpath('./'));

warning('on', 'MATLAB:rmpath:DirNotFound');
