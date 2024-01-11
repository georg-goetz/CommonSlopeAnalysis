function [insideBoundary, whichBoundary] = isInsideBoundary(pos, boundaries)
% Currently only works for rectangular rooms that are aligned with the
% coordinate axes
nBoundaries = length(boundaries);
insideBoundary = false;
whichBoundary = false(nBoundaries, 1);

% Go through all the sub-boundaries
for bIdx=1:nBoundaries
    theseVertices = reshape(boundaries{bIdx}.', 2, []).';
    boundaryMins = min(theseVertices);
    boundaryMaxs = max(theseVertices);

    if all(pos >= boundaryMins) && all(pos <= boundaryMaxs)
        insideBoundary = true;
        whichBoundary(bIdx) = true;
    end
end
end