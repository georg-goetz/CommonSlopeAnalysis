function analysisResults = commonSlopeAnalysis(rirs, fs, analysisBand, nAnalysisSlopes, nCommonSlopes, histResolution, plotFits)
%% Reshape for batch processing of Ambisonic responses (nRIRs x L x nChannels)
% Reshape and treat other channels than omni as additional RIRs
[nRIRs, L, nChannels] = size(rirs);
rirs = permute(rirs, [1, 3, 2]);
rirs = reshape(rirs, nRIRs*nChannels, L);

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
[aVals, nVals, dbMSE] = commonSlopeFit(edfs, commonDecayTimes, fs, plotFits);

disp('==== Common-slope decay analysis results ====');
fprintf('Mean MSE: %.02f dB.\n', dbMSE.avgMSE);
fprintf('Median MSE: %.02f dB, 95%% quantile: %.02f dB.\n', dbMSE.medianMSE, dbMSE.q95MSE);

%% Reshape for batch processing of Ambisonic responses (nRIR x L x nChannel)
% Reshape back into (nRIRs x nChannels x L)
aVals = reshape(aVals, nRIRs, nChannels, nCommonSlopes);
nVals = reshape(nVals, nRIRs, nChannels, 1);
aVals_standard = reshape(aVals_standard, nRIRs, nChannels, nAnalysisSlopes);
nVals_standard = reshape(nVals_standard, nRIRs, nChannels, 1);
tVals_standard = reshape(tVals_standard, nRIRs, nChannels, nAnalysisSlopes);
dbMSE.mseVals = reshape(dbMSE.mseVals, nRIRs, nChannels, 1);
dbMSE_standard.mseVals = reshape(dbMSE_standard.mseVals, nRIRs, nChannels, 1);

% Permute dimensions to get (nRIRs x L x nChannels)
aVals = permute(aVals, [1, 3, 2]);
nVals = permute(nVals, [1, 3, 2]);
aVals_standard = permute(aVals_standard, [1, 3, 2]);
nVals_standard = permute(nVals_standard, [1, 3, 2]);
tVals_standard = permute(tVals_standard, [1, 3, 2]);
dbMSE.mseVals = permute(dbMSE.mseVals, [1, 3, 2]);
dbMSE_standard.mseVals = permute(dbMSE_standard.mseVals, [1, 3, 2]);

%% Save analysis results to mat
analysisResults.analysisBand = analysisBand;
analysisResults.aVals = aVals;
analysisResults.nVals = nVals;
analysisResults.commonDecayTimes = commonDecayTimes;
analysisResults.aVals_standard = aVals_standard;
analysisResults.nVals_standard = nVals_standard;
analysisResults.tVals_standard = tVals_standard;
analysisResults.dbMSE = dbMSE;
analysisResults.dbMSE_standard = dbMSE_standard;
end