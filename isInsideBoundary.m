function insideBoundary = isInsideBoundary(pos, boundary)
% Currently only works for rectangular rooms that are aligned with the
% coordinate axes
insideBoundary = false;

% Go through all the sub-boundaries
for bIdx=1:length(boundary)
    theseVertices = reshape(boundary{bIdx}.', 2, []).';
    boundaryMins = min(theseVertices);
    boundaryMaxs = max(theseVertices);

    if all(pos >= boundaryMins) && all(pos <= boundaryMaxs)
        insideBoundary = true;
        break;
    end
end
end