function plotDecayTimeHist(clusteredTVals, commonDecayTimes, histResolution)
% Check dimensions
nCommonSlopes = length(commonDecayTimes);
assert(length(clusteredTVals) == nCommonSlopes, ['Mismatch between ' ...
    'clusteredTVals and commonDecayTimes: not the same number of common-slopes.']);
% Determine histogram edges
histEdges = histResolution2Edges(min(vertcat(clusteredTVals{:}), [], 'all'), ...
    max(vertcat(clusteredTVals{:}), [], 'all'), histResolution);

% Initialize cells with handles
histHandles = cell(nCommonSlopes, 1);
lineHandles = cell(nCommonSlopes, 1);
legendStr = cell(nCommonSlopes+1, 1);
maxOccurences = zeros(nCommonSlopes, 1);

figure;
hold on;
for mIdx=1:nCommonSlopes
    % Plot histogram of this mode group, find max number of occurences, 
    % and add entry to legend
    histHandles{mIdx} = histogram(clusteredTVals{mIdx}, histEdges);
    maxOccurences(mIdx) = max(histHandles{mIdx}.Values);
    legendStr{mIdx} = sprintf('$T_{%d,\\textbf{x}}$ values', mIdx);

    % Plot vertical line at common decay time and add text next to max bin
    lineHandles{mIdx} = xline(commonDecayTimes(mIdx), ':', 'LineWidth', 2);
    text(commonDecayTimes(mIdx)+0.075, maxOccurences(mIdx)*1.1, ...
        sprintf('$T_%d = %.02f\\ \\textrm{s}$', mIdx, commonDecayTimes(mIdx)), ...
        'FontSize', 18, 'Interpreter', 'latex');
end

% Determine and set axis limits
upperLim = max(maxOccurences);
tickRes = round(upperLim/5);
upperLim = (ceil(upperLim/tickRes)+1)*tickRes;
ylim([0, upperLim]);
yticks(0:tickRes:upperLim);

% Complete and show legend
legendStr{end} = 'Common decay times';
legend([histHandles{:}, lineHandles{1}], legendStr, 'Interpreter', 'latex', 'Location', 'NorthOutside', 'Orientation', 'horizontal');

% Axis labels
xlabel('Time [in s]');
ylabel('Number of occurrences [lin]');

% Cosmetic changes
set(gca,'TickDir','out', 'FontSize', 14, 'FontName', 'CMU Serif');
end