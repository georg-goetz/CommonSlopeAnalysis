function onBoundary = isOnBoundary(pos, boundaries)
onBoundary = false;

% Go through all the sub-boundaries
for bIdx=1:length(boundaries)
    theseEdges = boundaries{bIdx};

    % Go through all edges
    for eIdx=1:size(theseEdges, 1)
        vert1 = theseEdges(eIdx, 1:2);
        vert2 = theseEdges(eIdx, 3:4);
        
        % Pos is on line between vert1 and vert2, if dist(vert1,pos) +
        % dist(vert2,pos) = dist(vert1, vert2)
        if vecnorm(vert1-pos)+vecnorm(vert2-pos)-vecnorm(vert1-vert2) < 1e-6
            onBoundary = true;
            break;
        end
    end

    if onBoundary
        break;
    end
end
end