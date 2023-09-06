function [Y,Xf,Af] = myNeuralNetworkFunction3(X,~,~)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Auto-generated by MATLAB, 27-Aug-2023 01:08:38.
%
% [Y] = myNeuralNetworkFunction(X,~,~) takes these arguments:
%
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = Qx6 matrix, input #1 at timestep ts.
%
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = Qx2 matrix, output #1 at timestep ts.
%
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [13.5362042336695;65.7435999601554;11.1215672854821;0.00712008750965649;2.60018926156731;0.741201248599559];
x1_step1.gain = [0.0611658723237956;0.0180023920919794;0.0303036797360155;1.56176613691981;0.0659546354848031;0.279624087128405];
x1_step1.ymin = -1;

% Layer 1
b1 = [-1.9184832107769287379;-1.3036929778224302101;0.74990535541870528835;0.32223233888248653534;-0.099255896802674464796;0.89882117236354330814;-1.4783614768757633584;1.9720519505102120927];
IW1_1 = [0.20160949160560751037 -0.51572263487295932904 -1.4712185166718383389 -0.71079758385755098526 -1.0335702989046222644 0.30131500473439670751;0.82866829859563295724 -0.11672931273371853211 -0.96983081693967099213 -1.1293975809462559745 0.40820193474011723378 -0.75571951589443520092;-0.2828317905626968054 -0.91258210431929753792 0.96083932994530385496 -1.3424570729226958932 -0.30197832800033741485 0.66060179651819761482;-0.84007734672778910934 -0.87221838026563425217 -1.1070125279380300665 -0.38946197426681816722 -0.9803358417285816806 0.63563979292868255655;0.77584496123270219048 -0.72148502238301193135 -0.20669776115164117947 -0.41713441942637785598 1.4890225440062097029 -0.75659467669265423329;0.16136872463427687219 -0.081109919276827438517 -0.59605697178565519856 -0.081645584793267445001 -1.2108251199725235114 1.393211864734998473;-0.45571968510171712019 1.0006263793233820536 1.0314596740955959131 -0.19343008140919529247 -0.7819007730420076685 0.9399503133486618589;1.1031148684346019362 -0.84678959885481763781 1.262079873428515242 -0.53933627780150916742 0.3991874177947978275 -0.44679994295636815682];

% Layer 2
b2 = [-0.78206367003759946765;0.098004092504804921071];
LW2_1 = [-0.37916794208656579013 0.54180869936991316038 0.58716003766572688605 -0.093576163522105987314 0.81169243407911939592 -0.51423641834880462476 0.4099399744455904937 -0.26343422613026840073;-0.25948908686729255102 -0.6476647768353023249 -0.82565149263751269615 -0.47838019953294563802 -0.26947358469133680936 0.28025411638565234096 0.86822902130552892519 0.48965296521919743356];

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