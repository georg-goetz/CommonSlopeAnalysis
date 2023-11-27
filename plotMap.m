function [hAx, cAx, surfAx] = plotMap(mapVals, mapGrid, mapHeight, hAx, duplicateFig, cBarLabel, cBarLims, figSize)
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
surfAx = surf(hAx, mapGrid.XX, mapGrid.YY, 0*mapVals+mapHeight, mapVals, 'EdgeColor', 'none', 'FaceColor', 'interp');

% Colorbar
cAx = colorbar(hAx);
cAx.Label.Interpreter = 'latex';

if exist('cBarLabel', 'var') && ~isempty(cBarLabel)
    cAx.Label.String = cBarLabel;
end
if exist('cBarLims', 'var') && ~isempty(cBarLims)
    caxis(cBarLims);
end
end