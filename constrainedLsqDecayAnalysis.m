function kernelAmplitudes = constrainedLsqDecayAnalysis(edf_norm, decayKernel)
% Least-squares fit of decayKernel to EDF, using nonlinear least-squares
% (to fit on the dB scale) with non-negativity constraint
nSlopes = size(decayKernel, 2) - 1; % last column is noise part

% Minimize error between model fit (in dB) and true EDF (in dB). Clamp
% model to eps (to avoid -Inf values in dB) and 1 (initial part of EDF is a
% bit hard to model due to strong direct sound or heading zeros. Model fits
% late parts better in these  cases when model amplitudes are larger
% than 1, but this  introduces an error in the beginning that we 
% ignore here.)
% F = @(x) 10*log10(min(max(decayKernel(1:95, :)*x, eps), 1)) - 10*log10(edf_norm(1:95));
F = @(x) 10*log10(max(decayKernel(1:95, :)*x, eps)) - 10*log10(edf_norm(1:95));

% Init values for Least-squares fit
x0 = [ones(nSlopes, 1)*1; 1e-10];

% Upper and lower boundaries for parameters
xLower = zeros(nSlopes+1, 1);
xUpper = [ones(nSlopes, 1)*10; 1]; % allow larger than one for initial parts

% Set some fitting options for better accuracy and do fit
opt = optimoptions(@lsqnonlin, 'Display', 'off', ...
    'FunctionTolerance', 1e-9, 'StepTolerance', 1e-12, ...
    'MaxIterations', 1000); % 'MaxFunctionEvaluations', 5000, 
kernelAmplitudes = lsqnonlin(F, x0, xLower, xUpper, opt);
end