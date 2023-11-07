function edges = histResolution2Edges(minVal, maxVal, histResolution)
histMin = floor(minVal/histResolution)*histResolution;
histMax = ceil(maxVal/histResolution)*histResolution;
edges = histMin:histResolution:histMax;
end