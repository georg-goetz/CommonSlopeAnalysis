function analysisResults = commonSlopeAnalysis(rirs, fs, analysisBand, nAnalysisSlopes, nCommonSlopes, histResolution, plotFits)
%% Go through all SRIRs and do standard decay analysis
% Calculate EDFs for all RIRs
disp('==== Calculate EDFs ====');
[edfs, ~] = rir2decayBatch(rirs, fs, analysisBand, true, true, false);
edfs = [edfs{:}].'; % analyzing whole EDFs, i.e., without cutting initial part -> lengths are same

% Predict exponential model parameters
disp('==== Analyse EDFs with DecayFitNet ====');
[tVals_standard, aVals_standard, nVals_standard, ~, dbMSE_standard] = batchProcessing(rirs, 'ibic', nAnalysisSlopes, fs, analysisBand, false, plotFits);

disp('==== Standard decay analysis results ====');
fprintf('Mean MSE: %.02f dB.\n', dbMSE_standard.avgMSE);
fprintf('Median MSE: %.02f dB, 95%% quantile: %.02f dB.\n', dbMSE_standard.medianMSE, dbMSE_standard.q95MSE);

%% Determine common decay times from k-means method
[commonDecayTimes, clusteredTVals] = determineCommonDecayTimes(tVals_standard, nCommonSlopes, histResolution);

plotDecayTimeHist(clusteredTVals, commonDecayTimes, histResolution)

% Display results
disp('==== Determine common decay times ====');
for sIdx=1:nCommonSlopes
    fprintf('Common decay time T%d = %.02f s.\n', sIdx, commonDecayTimes(sIdx));
end

%% Fit common-slopes to measurements
[aVals, nVals, dbMSE_cs] = commonSlopeFit(edfs, commonDecayTimes, fs, plotFits);

disp('==== Common-slope decay analysis results ====');
fprintf('Mean MSE: %.02f dB.\n', dbMSE_cs.avgMSE);
fprintf('Median MSE: %.02f dB, 95%% quantile: %.02f dB.\n', dbMSE_cs.medianMSE, dbMSE_cs.q95MSE);

%% Save analysis results to mat
analysisResults.analysisBand = analysisBand;
analysisResults.aVals = aVals;
analysisResults.nVals = nVals;
analysisResults.commonDecayTimes = commonDecayTimes;
analysisResults.aVals_standard = aVals_standard;
analysisResults.tVals_standard = tVals_standard;
analysisResults.nVals_standard = nVals_standard;
analysisResults.dbMSE = dbMSE_cs;
analysisResults.dbMSE_standard = dbMSE_standard;
end