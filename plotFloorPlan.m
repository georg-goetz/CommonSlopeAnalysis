function hAx = plotFloorPlan(lineVertices, lineHeight, lineWidth, hAx, figSize)
% lineVertices: [lineIdx x (from xy, to xy)], or cell array with multiple
% arrays of that shape
if ~exist('lineHeight', 'var') || isempty(lineHeight)
    lineHeight = 1; % should be higher than map
end
if ~exist('lineWidth', 'var') || isempty(lineWidth)
    lineWidth = 4;
end
if ~exist('figSize', 'var')
    figSize = [200 200 700 700];
end
if ~exist('hAx', 'var') || isempty(hAx)
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

if iscell(lineVertices)
    nSubsets = length(lineVertices);
else
    nSubsets = 1;
    lineVertices = {lineVertices};
end

for sIdx=1:nSubsets
    thisSubset = lineVertices{sIdx};
    for lineIdx=1:size(thisSubset, 1)
        line(hAx, thisSubset(lineIdx, [1, 3]), thisSubset(lineIdx, [2, 4]), ...
            [lineHeight, lineHeight], 'Color', 'k', 'LineWidth', lineWidth);
    end
end