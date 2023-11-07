function hAx = plotSrcRcvPos(pos, posType, markerHeight, markerSize, markerColor, hAx)
if ~exist('markerHeight', 'var') || isempty(markerHeight)
    markerHeight = 1; % should be higher than map, if map is plotted
end
if ~exist('markerSize', 'var') || isempty(markerSize)
    markerSize = 100;
end
if ~exist('markerColor', 'var') || isempty(markerColor)
    markerColor = [0, 0, 0];
end
if ~exist('hAx', 'var') || isempty(hAx) 
    % Set up new figure if there isn't one yet
    figure('Position', [200 200 700 700]);
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
if strcmp(posType, 'src')
    markerStr = 'x';
elseif strcmp(posType, 'rcv')
    markerStr = 'filled';
else
    error('Unknown posType. Must be "src" or "rcv", but I got %s', posType);
end

for posIdx=1:size(pos, 1)
    scatter3(hAx, pos(posIdx, 1), pos(posIdx, 2), markerHeight, ...
        markerSize, markerStr, 'LineWidth', 2.5, 'MarkerFaceColor', ...
        markerColor, 'MarkerEdgeColor', markerColor);
end

end