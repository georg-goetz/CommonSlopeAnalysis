close all; clear variables; clc;
rng(42);

%% Calculate common-slope analysis on simulated data
fBands = [250, 500, 1000, 2000];
plotFits = false;
plotMaps = true;

histResolution = 0.05;
mapRes = 0.2;

dataDir = 'data';
datasetName = 'ertd1';

if strcmp(datasetName, 'ertd1')
    % Params for ERTD1
    allNAnalysisSlopes = [2, 2, 2, 2]; % nSlopes during traditional fitting
    allNCommonSlopes = [3, 3, 2, 2];
elseif strcmp(datasetName, 'ertd2')
    % Params for ERTD2
    allNAnalysisSlopes = [3, 3, 3, 3]; % nSlopes during traditional fitting
    allNCommonSlopes = [3, 3, 3, 3];
end

% Specify room walls as individual lines, given by [x_from, y_from, x_to, y_to]
% Room 1
walls_room1 = [0,7,0,13.6; 0,13.6,4.5,13.6; 4.5,13.6,4.5,10.4; 4.5,9.6,4.5,7; 4.5,7,0,7];

% Room 2
walls_room2 = [4.8,0,4.8,9.6; 4.8,10.4,4.8,18; 4.8,18,9.4,18; 9.4,18,9.4,0; 9.4,0,4.8,0]; 

% Transition
walls_room3 = [4.6,9.5,4.8,9.5; 4.6,10.5,4.8,10.5]; 

% Combine all walls into one cell
walls = {walls_room1, walls_room2, walls_room3};

% Plotting params
limsAndTicks.xLim = [0, 11];
limsAndTicks.yLim = [0, 18];
limsAndTicks.xTicks = 0:2.5:11;
limsAndTicks.yTicks = 0:2:18;
figSize = [200 200 800 450]; % posX, posY, sizeX, sizeY
colors = lines(3);

% Additional dependencies
toolboxDir = '/Users/gotzg1/Documents/MATLAB/Toolboxes';
deps = {'DecayFitNet', 'CommonSlopeAnalysis', 'export_fig', 'nanconv'};
for dIdx = 1:numel(deps)
    addpath(genpath(fullfile(toolboxDir, deps{dIdx})));
end

%% Check for problems
assert(length(fBands) == length(allNCommonSlopes), 'Number of common-slopes not specified for all frequency bands, or mismatch in number of specifications / number of bands.');
assert(length(fBands) == length(allNAnalysisSlopes), 'Number of  analysis slopes not specified for all frequency bands, or mismatch in number of specifications / number of bands.');

%% Load dataset
disp('==== Reading dataset ====')
disp('This may take a while.')
load(fullfile(dataDir, datasetName, sprintf('%s.mat', datasetName)));
rirs = ertd.rirs.';
srcPos = ertd.srcPos(1:3);
rcvPos = ertd.rcvPos;
fs = 48000;

clear ertd;

%% Do common-slope analysis in bands, get maps, and plot
for bIdx=3:length(fBands)
    rng(42);
    fprintf('======= Working on band %d Hz. =======\n', fBands(bIdx));
    analysisBand = fBands(bIdx);
    nAnalysisSlopes = allNAnalysisSlopes(bIdx);
    nCommonSlopes = allNCommonSlopes(bIdx);

    %% Do common-slope analysis
    analysisResults = commonSlopeAnalysis(rirs, fs, analysisBand, nAnalysisSlopes, nCommonSlopes, histResolution, plotFits);
    
    normVal = max(sum(analysisResults.aVals, 2));
    analysisResults.aVals = analysisResults.aVals / normVal;
    analysisResults.nVals = analysisResults.nVals / normVal;

    %% Calculate grid/map from values
    [mapAVals, mapGrid] = list2Map(analysisResults.aVals, rcvPos(:, 1:2), walls, mapRes);
    [mapNVals, ~] = list2Map(analysisResults.nVals, rcvPos(:, 1:2), walls, mapRes);
    [mapDbMSE, ~] = list2Map(analysisResults.dbMSE.mseVals, rcvPos(:, 1:2), walls, mapRes);
    
    %% Plot maps
    if plotMaps
        % Plot aVal maps
        if strcmp(datasetName, 'ertd1')
            cBarLims = [-20, 0; -19, -10; -45, -25]; %ERTD1
        elseif strcmp(datasetName, 'ertd2')
            cBarLims = [-25, 0; -30, -15; -45, -25]; %ERTD2
        end
        
        for sIdx=1:nCommonSlopes
            % Generate colorbar label
            cBarLabel = sprintf('$$A_{%d,\\textbf{x}}$$ [in dB]', sIdx);
        
            % Plot map
            [hAx, ~] = plotMap(10*log10(mapAVals(:, :, sIdx)), mapGrid, [], [], false, cBarLabel, cBarLims(sIdx,:), 5, figSize);
            
            % Plot floor plan
            plotFloorPlan(walls, [], [], hAx, figSize);
        
            % Add source to Figure
            plotSrcRcvPos(srcPos, 'src', [], [], colors(2,:), hAx);
            
            % Export Figure
            setLimsAndTicks(limsAndTicks);
            fname = sprintf('cs_analysis_%dHz_a%d.pdf', analysisBand, sIdx);
            export_fig(fullfile(dataDir, datasetName, fname));
        end
        
        % Plot nVal map and export figure
        cBarLabel = '$$N_{0,\textbf{x}}$$ [in dB]';
        [hAx, ~] = plotMap(10*log10(mapNVals), mapGrid, [], [], false, cBarLabel, [-100, 0], 5, figSize);
        plotFloorPlan(walls, [], [], hAx, figSize);
        plotSrcRcvPos(srcPos, 'src', [], [], colors(2,:), hAx);
        setLimsAndTicks(limsAndTicks);
        fname = sprintf('cs_analysis_%dHz_n.pdf', analysisBand);
        export_fig(fullfile(dataDir, datasetName, fname));
        
        % Plot dBMSE map
        cBarLabel = 'dB-MSE [in dB]';
        [hAx, ~] = plotMap(mapDbMSE, mapGrid, [], [], false, cBarLabel, [0, 3], 1, figSize);
        plotFloorPlan(walls, [], [], hAx, figSize);
        plotSrcRcvPos(srcPos, 'src', [], [], colors(2,:), hAx);
        setLimsAndTicks(limsAndTicks);
        fname = sprintf('cs_analysis_%dHz_dbMSE.pdf', analysisBand);
        export_fig(fullfile(dataDir, datasetName, fname));
    end
    
    %% Save analysis results to mat
    analysisResults.srcPos = srcPos;
    analysisResults.rcvPos = rcvPos;
    analysisResults.room_walls = walls;
    analysisResults.mapGrid = mapGrid;
    analysisResults.mapAVals = mapAVals;
    analysisResults.mapNVals = mapNVals;
    analysisResults.mapDbMSE = mapDbMSE;
    analysisResults.mapRes = mapRes;
    
    save(fullfile(dataDir, datasetName, sprintf('cs_analysis_results_%d.mat', analysisBand)), 'analysisResults', '-v7.3');
end

%% Functions
function setLimsAndTicks(limsAndTicks)
    xlim(limsAndTicks.xLim);
    ylim(limsAndTicks.yLim);
    xticks(limsAndTicks.xTicks);
    yticks(limsAndTicks.yTicks);
end