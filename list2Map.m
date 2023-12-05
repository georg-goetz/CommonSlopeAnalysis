function [mapVals, mapGrid] = list2Map(listVals, listPos, mapBoundaries, mapRes)
% listVals: [nEntries x nValues] 
% listPos: [nEntries x 2]
% mapBoundaries: cell array where each entry can specify a subset of the
%                boundary (e.g. individual rooms) as a list of lines
%                [nLines x (from xy, to xy)]. For a basic rectangular map,
%                the cell array only needs one entry with a list of 4 lines
%                delimiting the boundary
% mapRes: scalar resolution (same in x and y)
vertices = reshape(vertcat(mapBoundaries{:}).', 2, []).';
mapMins = min(vertices);
mapMaxs = max(vertices);
xAx = mapMins(1):mapRes:mapMaxs(1);
yAx = mapMins(2):mapRes:mapMaxs(2);
[XX, YY] = meshgrid(xAx, yAx);

mapVals = nan([size(XX), size(listVals, [2, 3])]);
for mapIdx=1:numel(XX)
    if isInsideBoundary([XX(mapIdx), YY(mapIdx)], mapBoundaries)
        distancesToListPos = vecnorm(listPos - [XX(mapIdx), YY(mapIdx)], 2, 2);
        [~, closestPosIdx] = min(distancesToListPos);

        [row, col] = ind2sub(size(XX), mapIdx);
        mapVals(row, col, :, :) = listVals(closestPosIdx, :, :);
    end
end

mapGrid.XX = XX;
mapGrid.YY = YY;
end