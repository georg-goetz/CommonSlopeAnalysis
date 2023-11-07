function [aVals, nVals, dbMSE] = commonSlopeAnalysis(edfs, commonDecayTimes, fs, plotFits)
% Normalize EDFs
normVals = edfs(:, 1); % 1 is also max in Schroeder curves
edfs_norm = edfs ./ normVals;

% Initialize decay kernel
L = size(edfs, 2);
timeAxis_ds = linspace(0, (L - 1) / fs, 100);
decayKernel_ds = decayKernel(commonDecayTimes, timeAxis_ds.');

nEDFs = size(edfs, 1);
nCommonSlopes = length(commonDecayTimes);
aVals = zeros(nEDFs, nCommonSlopes);
nVals = zeros(nEDFs, 1);
mseVals = zeros(nEDFs, 1);

for mIdx=1:nEDFs  
    % Resample EDF to 100 samples
    thisEDF_norm_ds = resample(edfs_norm(mIdx, :).', 100, L, 0, 5);
    thisEDF_norm_db_ds = 10*log10(thisEDF_norm_ds);
    thisEDF_db_ds = thisEDF_norm_db_ds + 10*log10(normVals(mIdx)); % un-normalize

    % Least squares fit of decay kernel to EDF
    theseKernelAmplitudes = constrainedLsqDecayAnalysis(thisEDF_norm_ds, decayKernel_ds).';
    
    % Un-normalize to get back correct amplitudes
    aVals(mIdx, :) = theseKernelAmplitudes(1:nCommonSlopes) * normVals(mIdx);
    nVals(mIdx) = theseKernelAmplitudes(end) * normVals(mIdx);
    
    % Get EDF model from estimated parameters
    fittedEDF_norm_db_ds = 10*log10(decayKernel_ds*theseKernelAmplitudes.');
    fittedEDF_db_ds = fittedEDF_norm_db_ds + 10*log10(normVals(mIdx)); % un-normalize
    
    % Calculate dbMSE between EDF and model, exclude last 5% 
    mseVals(mIdx) = mseLoss(thisEDF_norm_db_ds(1:95), fittedEDF_norm_db_ds(1:95));
   
    % Plot if desired
    if plotFits
        if mIdx==1
            yMax = ceil(log10(max(normVals)))*10;
            yMin = yMax - 130;

            figure;
            hold on;
            h_edf = plot(timeAxis_ds, thisEDF_db_ds, 'LineWidth', 1.5);
            h_fittedEDF = plot(timeAxis_ds, fittedEDF_db_ds, 'LineWidth', 1.5);
            legend('True EDF', 'Fitted EDF');
            xlabel('Time [in s]');
            ylabel('Energy [in dB]');
            ylim([yMin, yMax]);
            yticks(yMin:20:yMax);
            set(gca, 'FontSize', 14', 'FontName', 'CMU Serif');
            grid on;
        else
            set(h_edf, 'YData', thisEDF_db_ds);
            set(h_fittedEDF, 'YData', fittedEDF_db_ds);
        end
        title(sprintf('Common-slope fit for measurement %d', mIdx));
        drawnow;
    end
end

% Build up MSE struct: mean, median, 95 quant., all MSEs
mseQuantiles = quantile(mseVals, [0.5, 0.95]);
dbMSE.mseVals = mseVals;
dbMSE.avgMSE = mean(mseVals);
dbMSE.medianMSE = mseQuantiles(1);
dbMSE.q95MSE = mseQuantiles(2);

end