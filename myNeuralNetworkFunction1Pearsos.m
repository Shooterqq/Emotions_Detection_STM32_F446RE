function [Y,Xf,Af] = myNeuralNetworkFunction1Pearsos(X,~,~)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Auto-generated by MATLAB, 09-Sep-2023 03:10:09.
%
% [Y] = myNeuralNetworkFunction(X,~,~) takes these arguments:
%
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = Qx5 matrix, input #1 at timestep ts.
%
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = Qx2 matrix, output #1 at timestep ts.
%
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [9.87792268371849;79.2331054140722;11.3679848881848;0.0112489584604173;0.29800584881315];
x1_step1.gain = [0.208421527478348;0.103554896996933;0.0709824782928914;7.45504259679016;4.02124078409248];
x1_step1.ymin = -1;

% Layer 1
b1 = [2.368123099541919796;1.4874105777416730678;1.3587575396747972878;-0.63221145067479667112;-1.9462267856932435883];
IW1_1 = [-0.35605253956493171374 0.20215160720029037855 -0.55250182832675176492 -0.031008879117127973596 1.333930578531536959;-0.95733110265828957886 1.4801541229093870822 0.51899563288799466232 -0.13356820456910695194 1.2918795406804881587;2.9835885830530481932 -1.2899462146213720448 -2.0343069022475019914 2.004004867462827022 0.45304606179163309232;-3.4341940173619658339 0.81282473819175893315 0.53368989682302814259 -0.45418541366096804035 0.35236224867098775437;-1.0369740451393061331 -0.8433500037603226529 0.52637440653494493858 0.89522365880819665396 -0.87213884490888871071];

% Layer 2
b2 = [-0.626223247886059875;-0.094066641602318729065];
LW2_1 = [0.31784843966802911464 1.3143085086706147724 -3.6209750436262324591 2.7437418857330686528 1.4496703466386142711;0.12782442710408165043 -0.4114597001562783074 3.9678294432566669769 -3.3423491170465773337 0.097658687275448213816];

% ===== SIMULATION ========

% Format Input Arguments
isCellX = iscell(X);
if ~isCellX
    X = {X};
end

% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
    Q = size(X{1},1); % samples/series
else
    Q = 0;
end

% Allocate Outputs
Y = cell(1,TS);

% Time loop
for ts=1:TS
    
    % Input 1
    X{1,ts} = X{1,ts}';
    Xp1 = mapminmax_apply(X{1,ts},x1_step1);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = softmax_apply(repmat(b2,1,Q) + LW2_1*a1);
    
    % Output 1
    Y{1,ts} = a2;
    Y{1,ts} = Y{1,ts}';
end

% Final Delay States
Xf = cell(1,0);
Af = cell(2,0);

% Format Output Arguments
if ~isCellX
    Y = cell2mat(Y);
end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Competitive Soft Transfer Function
function a = softmax_apply(n,~)
if isa(n,'gpuArray')
    a = iSoftmaxApplyGPU(n);
else
    a = iSoftmaxApplyCPU(n);
end
end
function a = iSoftmaxApplyCPU(n)
nmax = max(n,[],1);
n = bsxfun(@minus,n,nmax);
numerator = exp(n);
denominator = sum(numerator,1);
denominator(denominator == 0) = 1;
a = bsxfun(@rdivide,numerator,denominator);
end
function a = iSoftmaxApplyGPU(n)
nmax = max(n,[],1);
numerator = arrayfun(@iSoftmaxApplyGPUHelper1,n,nmax);
denominator = sum(numerator,1);
a = arrayfun(@iSoftmaxApplyGPUHelper2,numerator,denominator);
end
function numerator = iSoftmaxApplyGPUHelper1(n,nmax)
numerator = exp(n - nmax);
end
function a = iSoftmaxApplyGPUHelper2(numerator,denominator)
if (denominator == 0)
    a = numerator;
else
    a = numerator ./ denominator;
end
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end
