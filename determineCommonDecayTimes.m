function [commonDecayTimes, clusteredTVals] = determineCommonDecayTimes(tVals, nCommonSlopes, histResolution)
commonDecayTimes = zeros(nCommonSlopes, 1);
clusteredTVals = cell(nCommonSlopes, 1);

% Get all non-zero T
nonZeroT = tVals(tVals > 0);

% K-means clustering of T values
[tIdx2ClusterIdx, clusterCentroids] = kmeans(nonZeroT, nCommonSlopes, 'distance', 'cityblock', 'MaxIter', 10000, 'Replicates', 5);
[~, sortClusterIdx] = sort(clusterCentroids);

% Histograms of clusters: common decay times are peaks in histograms
histEdges = histResolution2Edges(min(nonZeroT), max(nonZeroT), histResolution);
for mIdx=1:nCommonSlopes
    clusteredTVals{mIdx} = nonZeroT(tIdx2ClusterIdx==sortClusterIdx(mIdx));
    [nCounts, ~] = histcounts(clusteredTVals{mIdx}, histEdges);
    [~, maxCountIdx] = max(nCounts);
    commonDecayTimes(mIdx) = mean(histEdges(maxCountIdx:maxCountIdx+1));
end
end