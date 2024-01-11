function [hAx, cAx, surfAx] = plotMap(mapVals, mapGrid, mapHeight, hAx, duplicateFig, cBarLabel, cBarLims, cBarDelta, figSize)
if ~exist('mapHeight', 'var') || isempty(mapHeight)
    mapHeight = 0; % should be lower than floor plan or src/rcv pos
end
if ~exist('figSize', 'var') || isempty(figSize)
    figSize = [200 200 700 700];
end
if ~exist('hAx', 'var') || isempty(hAx) 
    % Set up new figure if there isn't one yet
    figure('Position', figSize);
    hold on;
    xlabel('$$x$$ [in m]', 'Interpreter', 'latex');
    ylabel('$$y$$ [in m]', 'Interpreter', 'latex');
    view(0, 90);
    set(gca, 'FontSize', 24, 'FontName', 'CMU Serif', 'TickDir', 'out');
    set(gcf, 'Color', 'w');
    grid off
    axis equal;
    hAx = gca;
end
if ~exist('duplicateFig', 'var')
    duplicateFig = false;
end
if duplicateFig
    % Copy all children (Axes + Colorbar) from old figure to new one
    fNew = figure;
    fOld = hAx.Parent;
    newChildren = copyobj(fOld.Children, fNew);

    % Get only the Axes to replace surface plot later
    isAxis = arrayfun(@(x) isa(x, 'matlab.graphics.axis.Axes'), newChildren);
    hAx = newChildren(isAxis);
    
    set(fNew, 'Color', 'w', 'Position', figSize);
end

% Surface plot with map values
% mapVals = imgaussfilt(mapVals, 1.5, 'FilterDomain', 'spatial');
filtWidth = 3;
filtSigma = 2;
imageFilter=fspecial('gaussian',filtWidth,filtSigma);
try
    mapVals = nanconv(mapVals,imageFilter, 'nanout');
catch
    disp('=== WARNING ===');
    disp('Looks like the nanconv function is missing.');
    disp('It makes the plots smooth and a bit nicer (no spilling over between rooms).')
    disp('You can get it from here: https://se.mathworks.com/matlabcentral/fileexchange/41961-nanconv');
    disp('Plotting without interpolation for now.');
end

surfAx = surf(hAx, mapGrid.XX, mapGrid.YY, 0*mapVals+mapHeight, mapVals, 'EdgeColor', 'none', 'FaceColor', 'interp');

% Colorbar
cAx = colorbar(hAx);
cAx.Label.Interpreter = 'latex';

if exist('cBarLabel', 'var') && ~isempty(cBarLabel)
    cAx.Label.String = cBarLabel;
end
if exist('cBarLims', 'var') && ~isempty(cBarLims)
    clim(cBarLims);
end
if exist('cBarDelta', 'var') && ~isempty(cBarDelta)
    cAx.XTick = cBarLims(1):cBarDelta:cBarLims(2);
end
end